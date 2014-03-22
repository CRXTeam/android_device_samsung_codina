/*
 * Copyright (C) 2012 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.cyanogenmod.settings.device;

import java.io.IOException;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.PreferenceManager;
import android.util.AttributeSet;

public class TCPControl extends ListPreference implements
		OnPreferenceChangeListener {
	
	public TCPControl(Context context, AttributeSet attrs) {
		super(context, attrs);
		this.setOnPreferenceChangeListener(this);
	}
	
	static Process process;
	static String newValueString;
	
	final static String[] COMMAND = {
			"su", "-c",
			"busybox sysctl -w net.ipv4.tcp_congestion_control=" +
			newValueString
		};
	
	/**
	 * Restore TCP Control algorithm from SharedPreferences.
	 * 
	 * @param context
	 *            The context to read the SharedPreferences from
	 */
	public static void restore(Context context) {
		SharedPreferences sharedPrefs = PreferenceManager
				.getDefaultSharedPreferences(context);
		newValueString = sharedPrefs.getString(DeviceSettings.KEY_TCP_CONTROL, "cubic");
		try {
			process = Runtime.getRuntime().exec(COMMAND);
			process.waitFor();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	@Override
	public boolean onPreferenceChange(Preference preference, Object newValue) {
		newValueString = (String) newValue;
		try {
			process = Runtime.getRuntime().exec(COMMAND);
			process.waitFor();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		return true;
	}

}