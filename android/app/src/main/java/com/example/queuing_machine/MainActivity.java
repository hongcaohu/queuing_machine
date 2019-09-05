package com.example.queuing_machine;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    this.init();
  }

    private static final String ACTION_USB_PERMISSION = "com.example.queuing_machine.USB_PERMISSION";
    private android.hardware.usb.UsbManager mUsbManager;
    private android.app.PendingIntent mPermissionIntent;
    private android.content.BroadcastReceiver mUsbReceiver = new android.content.BroadcastReceiver() {
        public void onReceive(android.content.Context context, android.content.Intent intent) {
            //android.util.Log.d(TAG, "onReceive: " + intent);
            String action = intent.getAction();
            if (action == null)
                return;
            switch (action) {
                case ACTION_USB_PERMISSION://用户授权广播
                    synchronized (this) {
                        if (intent.getBooleanExtra(android.hardware.usb.UsbManager.EXTRA_PERMISSION_GRANTED, false)) { //允许权限申请
                            test();
                        } else {
                            android.util.Log.d("用户未授权，访问USB设备失败","");
                        }
                    }
                    break;
                case android.hardware.usb.UsbManager.ACTION_USB_DEVICE_ATTACHED://USB设备插入广播
                    android.util.Log.d("USB设备插入","");
                    test();
                    break;
                case android.hardware.usb.UsbManager.ACTION_USB_DEVICE_DETACHED://USB设备拔出广播
                    android.util.Log.d("USB设备拔出","");
                    break;
            }
        }
    };

    private void init() {
        //USB管理器
        mUsbManager = (android.hardware.usb.UsbManager) getSystemService(android.content.Context.USB_SERVICE);
        mPermissionIntent = android.app.PendingIntent.getBroadcast(this, 0, new android.content.Intent(ACTION_USB_PERMISSION), 0);

        //注册广播,监听USB插入和拔出
        android.content.IntentFilter intentFilter = new android.content.IntentFilter();
        intentFilter.addAction(android.hardware.usb.UsbManager.ACTION_USB_DEVICE_ATTACHED);
        intentFilter.addAction(android.hardware.usb.UsbManager.ACTION_USB_DEVICE_DETACHED);
        intentFilter.addAction(ACTION_USB_PERMISSION);
        registerReceiver(mUsbReceiver, intentFilter);

        //读写权限
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            requestPermissions(new String[]{android.Manifest.permission.WRITE_EXTERNAL_STORAGE,
                    android.Manifest.permission.READ_EXTERNAL_STORAGE}, 111);
        }
    }

    private void test() {
        try {
            com.github.mjdev.libaums.UsbMassStorageDevice[] storageDevices = com.github.mjdev.libaums.UsbMassStorageDevice.getMassStorageDevices(this);
            for (com.github.mjdev.libaums.UsbMassStorageDevice storageDevice : storageDevices) { //一般手机只有一个USB设备
                // 申请USB权限
                if (!mUsbManager.hasPermission(storageDevice.getUsbDevice())) {
                    mUsbManager.requestPermission(storageDevice.getUsbDevice(), mPermissionIntent);
                    break;
                }
                // 初始化
                storageDevice.init();
                // 获取分区
                java.util.List<com.github.mjdev.libaums.partition.Partition> partitions = storageDevice.getPartitions();
                if (partitions.size() == 0) {
                    android.util.Log.d("错误: 读取分区失败","");
                    return;
                }
                // 仅使用第一分区
                com.github.mjdev.libaums.fs.FileSystem fileSystem = partitions.get(0).getFileSystem();
                logShow("Volume Label: " + fileSystem.getVolumeLabel());
                logShow("Capacity: " + fSize(fileSystem.getCapacity()));
                logShow("Occupied Space: " + fSize(fileSystem.getOccupiedSpace()));
                logShow("Free Space: " + fSize(fileSystem.getFreeSpace()));
                logShow("Chunk size: " + fSize(fileSystem.getChunkSize()));

                com.github.mjdev.libaums.fs.UsbFile root = fileSystem.getRootDirectory();
                com.github.mjdev.libaums.fs.UsbFile[] files = root.listFiles();
                for (com.github.mjdev.libaums.fs.UsbFile file : files)
                    logShow("文件: " + file.getName());

                // 新建文件
                com.github.mjdev.libaums.fs.UsbFile newFile = root.createFile("hello_" + System.currentTimeMillis() + ".txt");
                logShow("新建文件: " + newFile.getName());

                // 写文件
                // OutputStream os = new UsbFileOutputStream(newFile);
                java.io.OutputStream os = com.github.mjdev.libaums.fs.UsbFileStreamFactory.createBufferedOutputStream(newFile, fileSystem);
                os.write(("hi_" + System.currentTimeMillis()).getBytes());
                os.close();
                logShow("写文件: " + newFile.getName());

                // 读文件
                // InputStream is = new UsbFileInputStream(newFile);
                java.io.InputStream is = com.github.mjdev.libaums.fs.UsbFileStreamFactory.createBufferedInputStream(newFile, fileSystem);
                byte[] buffer = new byte[fileSystem.getChunkSize()];
                int len;
                java.io.File sdFile = new java.io.File("/sdcard/111");
                sdFile.mkdirs();
                java.io.FileOutputStream sdOut = new java.io.FileOutputStream(sdFile.getAbsolutePath() + "/" + newFile.getName());
                while ((len = is.read(buffer)) != -1) {
                    sdOut.write(buffer, 0, len);
                }
                is.close();
                sdOut.close();
                logShow("读文件: " + newFile.getName() + " ->复制到/sdcard/111/");

                storageDevice.close();
            }
        } catch (Exception e) {
            logShow("错误: " + e);
        }
    }

    private void logShow(String message) {
        android.util.Log.d(message, "");
    }

    public static String fSize(long sizeInByte) {
        if (sizeInByte < 1024)
            return String.format("%s", sizeInByte);
        else if (sizeInByte < 1024 * 1024)
            return String.format(java.util.Locale.CANADA, "%.2fKB", sizeInByte / 1024.);
        else if (sizeInByte < 1024 * 1024 * 1024)
            return String.format(java.util.Locale.CANADA, "%.2fMB", sizeInByte / 1024. / 1024);
        else
            return String.format(java.util.Locale.CANADA, "%.2fGB", sizeInByte / 1024. / 1024 / 1024);
    }
}
