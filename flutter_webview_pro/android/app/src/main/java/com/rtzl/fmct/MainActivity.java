package com.rtzl.fmct;

import android.os.BatteryManager;

import android.widget.Toast;
import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

import java.util.List;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL_GETTER = "com.rtzl.zbc/get/battery";
    private static final String CHANNEL_ACTION = "com.rtzl.zbc/action/toast";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        BinaryMessenger messager = flutterEngine.getDartExecutor().getBinaryMessenger();

        new MethodChannel(messager, CHANNEL_GETTER)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getBatteryLevel")) {
                                int batteryLevel = getBatteryLevel();
                                if (batteryLevel != -1) {
                                    result.success(batteryLevel);
                                } else {
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            } else {
                                result.notImplemented();
                            }
                        }
                );
        new MethodChannel(messager, CHANNEL_ACTION)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("toast")) {
                                // Display Toast info
                                String content = (String) call.arguments;
                                Toast toast = Toast.makeText(getBaseContext(), content, Toast.LENGTH_LONG);
                                toast.show();
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private int getBatteryLevel() {
        int batteryLevel = -1;
        BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
        batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        return batteryLevel;
    }
}