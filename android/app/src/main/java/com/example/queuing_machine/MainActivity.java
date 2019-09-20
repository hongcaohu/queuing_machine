package com.example.queuing_machine;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;

import com.github.mjdev.libaums.UsbMassStorageDevice;
import com.github.mjdev.libaums.fs.FileSystem;
import com.github.mjdev.libaums.fs.UsbFile;
import com.github.mjdev.libaums.fs.UsbFileStreamFactory;
import com.github.mjdev.libaums.partition.Partition;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.List;
import java.util.Locale;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

public class MainActivity extends FlutterActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    this.init();
    GeneratedPluginRegistrant.registerWith(this);
    this.doFlutterChannel();
  }

    private static final String ACTION_USB_PERMISSION = "com.example.queuing_machine.USB_PERMISSION";
    private UsbManager mUsbManager;
    private PendingIntent mPermissionIntent;
    private BroadcastReceiver mUsbReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
            //android.util.Log.d(TAG, "onReceive: " + intent);
            String action = intent.getAction();
            if (action == null)
                return;
            switch (action) {
                case ACTION_USB_PERMISSION://用户授权广播
                    synchronized (this) {
                        if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) { //允许权限申请
                            test();
                        } else {
                            Log.d("用户未授权，访问USB设备失败","");
                        }
                    }
                    break;
                case UsbManager.ACTION_USB_DEVICE_ATTACHED://USB设备插入广播
                    Log.d("USB设备插入","");
                    test();
                    break;
                case UsbManager.ACTION_USB_DEVICE_DETACHED://USB设备拔出广播
                    Log.d("USB设备拔出","");
                    break;
            }
        }
    };

    private void init() {
        //USB管理器
        mUsbManager = (UsbManager) getSystemService(Context.USB_SERVICE);
        mPermissionIntent = PendingIntent.getBroadcast(this, 0, new Intent(ACTION_USB_PERMISSION), 0);

        //注册广播,监听USB插入和拔出
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED);
        intentFilter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
        intentFilter.addAction(ACTION_USB_PERMISSION);
        registerReceiver(mUsbReceiver, intentFilter);

        //读写权限
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(new String[]{WRITE_EXTERNAL_STORAGE,
                    READ_EXTERNAL_STORAGE}, 111);
        }
    }

    private static final String BASIC_CHANNEL_NAME = "sywl_basicMessageChannel";
    private void doFlutterChannel() {
        String dataDir = this.getApplication().getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS).getPath();
        BasicMessageChannel messageChannel = new BasicMessageChannel(this.getFlutterView(), BASIC_CHANNEL_NAME, StandardMessageCodec.INSTANCE);
        messageChannel.setMessageHandler(new BasicMessageChannel.MessageHandler<String>(){
            @Override
            public void onMessage(String s, BasicMessageChannel.Reply<String> reply) {
                reply.reply(dataDir);
            }
        });
    }

    private void test() {
        try {
            UsbMassStorageDevice[] storageDevices = UsbMassStorageDevice.getMassStorageDevices(this);
            for (UsbMassStorageDevice storageDevice : storageDevices) { //一般手机只有一个USB设备
                // 申请USB权限
                if (!mUsbManager.hasPermission(storageDevice.getUsbDevice())) {
                    mUsbManager.requestPermission(storageDevice.getUsbDevice(), mPermissionIntent);
                    break;
                }
                // 初始化
                storageDevice.init();
                // 获取分区
                List<Partition> partitions = storageDevice.getPartitions();
                if (partitions.size() == 0) {
                    Log.d("错误: 读取分区失败","");
                    return;
                }
                // 仅使用第一分区
                FileSystem fileSystem = partitions.get(0).getFileSystem();
                logShow("Volume Label: " + fileSystem.getVolumeLabel());
                logShow("Capacity: " + fSize(fileSystem.getCapacity()));
                logShow("Occupied Space: " + fSize(fileSystem.getOccupiedSpace()));
                logShow("Free Space: " + fSize(fileSystem.getFreeSpace()));
                logShow("Chunk size: " + fSize(fileSystem.getChunkSize()));

                UsbFile root = fileSystem.getRootDirectory();
                /*UsbFile[] files = root.listFiles();
                for (UsbFile file : files)
                    logShow("文件: " + file.getName());

                // 新建文件
                UsbFile newFile = root.createFile("hello_" + System.currentTimeMillis() + ".txt");
                logShow("新建文件: " + newFile.getName());

                // 写文件
                // OutputStream os = new UsbFileOutputStream(newFile);
                OutputStream os = UsbFileStreamFactory.createBufferedOutputStream(newFile, fileSystem);
                os.write(("hi_" + System.currentTimeMillis()).getBytes());
                os.close();
                logShow("写文件: " + newFile.getName());*/

                // 读文件
                // InputStream is = new UsbFileInputStream(newFile);
/*                InputStream is = UsbFileStreamFactory.createBufferedInputStream(newFile, fileSystem);
                byte[] buffer = new byte[fileSystem.getChunkSize()];
                int len;
                File sdFile = new File("/sdcard/111");
                sdFile.mkdirs();
                FileOutputStream sdOut = new FileOutputStream(sdFile.getAbsolutePath() + "/" + newFile.getName());
                while ((len = is.read(buffer)) != -1) {
                    sdOut.write(buffer, 0, len);
                }
                is.close();
                sdOut.close();
                logShow("读文件: " + newFile.getName() + " ->复制到/sdcard/111/");*/

                //开始同步U盘数据
                this.sendToFlutter("begin");

                //从指定目录读取文件（图片、视频、文字）等，存在android设备本地，用于app端展示
                UsbFile[] syFiles = root.listFiles();
                for(UsbFile f : syFiles) {
                    if(f.isDirectory() && "sywl".equals(f.getName())) {
                        String base_path = this.getApplication().getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS).getPath();
                        InputStream is = UsbFileStreamFactory.createBufferedInputStream(f, fileSystem);
                        byte[] buffer = new byte[fileSystem.getChunkSize()];
                        int len;
                        File sdFile = new File(base_path + "/res/");
                        //如果已经存在，先删除
                        if(sdFile.exists()) {
                            sdFile.delete();
                        }
                        sdFile.mkdirs();
                        FileOutputStream sdOut = new FileOutputStream(sdFile.getAbsolutePath() + "/" + f.getName());
                        while ((len = is.read(buffer)) != -1) {
                            sdOut.write(buffer, 0, len);
                        }
                        is.close();
                        sdOut.close();
                        logShow("读文件: " + f.getName() + "->复制到" + base_path + "/res/");
                    }
                }
                storageDevice.close();
                //同步U盘数据完成
                this.sendToFlutter("end");
            }
        } catch (Exception e) {
            logShow("错误: " + e);
        }
    }

    private void sendToFlutter(String message) {
        BasicMessageChannel messageChannel = new BasicMessageChannel(this.getFlutterView(), BASIC_CHANNEL_NAME, StandardMessageCodec.INSTANCE);
        messageChannel.send(message);
    }

    private void logShow(String message) {
        Log.d(message, "");
    }

    public static String fSize(long sizeInByte) {
        if (sizeInByte < 1024)
            return String.format("%s", sizeInByte);
        else if (sizeInByte < 1024 * 1024)
            return String.format(Locale.CANADA, "%.2fKB", sizeInByte / 1024.);
        else if (sizeInByte < 1024 * 1024 * 1024)
            return String.format(Locale.CANADA, "%.2fMB", sizeInByte / 1024. / 1024);
        else
            return String.format(Locale.CANADA, "%.2fGB", sizeInByte / 1024. / 1024 / 1024);
    }
}
