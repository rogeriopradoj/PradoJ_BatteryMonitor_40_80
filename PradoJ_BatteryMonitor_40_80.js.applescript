function batteryInfo() {
	
	const strPmsetDrawing = {
		pre: "Now drawing from '",
		post: " Power'"
	};
	const strPmsetPercentage = {
		pre: ")\t",
		post: "%;"
	};
	
	var	info = {
		sourcePower: '',
		percentage: 0
	};

	app = Application.currentApplication();
	app.includeStandardAdditions = true;
	infoPmset = app.doShellScript('pmset -g batt');
	
	info.sourcePower = infoPmset.substring(
		strPmsetDrawing.pre.length,
		infoPmset.indexOf(strPmsetDrawing.post)
	);
	
	info.percentage = infoPmset.substring(
		infoPmset.indexOf(strPmsetPercentage.pre) + strPmsetPercentage.pre.length,
		infoPmset.indexOf(strPmsetPercentage.post)
	);
	
	// Now drawing from 'AC Power'\r -InternalBattery-0 (id=4980835)\t56%; AC attached; not charging present: true"
	
	// Now drawing from 'Battery Power'\r -InternalBattery-0 (id=4980835)\t57%; discharging; (no estimate) present: true

	return info;

}

function isBatteryInRange(range, info) {
	
	var isBatteryInRange = false;
	var info = info;
	
	if (
		info.percentage >= range.min
		&& info.percentage <= range.max
	) {
  		isBatteryInRange = true;
	}
		
	return isBatteryInRange;
	
}

function isBatteryAboveRange(range, info) {
	
	// {"sourcePower":"Battery", "percentage":"72"}
	var isAbove = false;
	var range = range;
	var info = info;
	
	if (info.percentage > range.max) {
		isAbove = true;
	};
	
	return isAbove;
	
}

function isBatteryBelowRange(range, info) {
	
	var isBelow = false;
	var range = range;
	var info = info;
	
	if (info.percentage < range.min) {
		isBelow = true;
	};
	
	return isBelow;
	
}

function sayConnectCharger(info) {
	if (info.sourcePower === 'AC') {
		return;
	}
	
	app.beep(1);
	
	for (var i = 0; i < 3; i++) {
		app.say("Attention " + info.percentage + "%" + ". Connect the power charger.", {
			using: "Alex"
		});
		
		app.displayNotification(info.percentage + "%" + ". Connect the power charger.", {
			withTitle: "PradoJ BatteryMonitor",
			subtitle: "Attention",
			soundName: "Glass"
		});
	}
}

function sayDisconnectCharger(info) {
	if (info.sourcePower === 'Battery') {
		return;
	}
	
	app.beep(1);
	
	for (var i = 0; i < 3; i++) {
		app.say(
			"Attention " + info.percentage + "%" + ". Disconnect the power charger.", {
				using: "Alex"
		});
		
		app.displayNotification(
			info.percentage + "%" + ". Disconnect the power charger.", {
				withTitle: "PradoJ BatteryMonitor",
				subtitle: "Attention",
				soundName: "Glass"
		});
	}
}

var config = {
	range: {
		min: 40,
		max: 80,
	}
};

var app = Application.currentApplication();
app.includeStandardAdditions = true;

while(true) {

	delay(120);

	if (isBatteryInRange(config.range, batteryInfo())) {
		app.displayNotification(batteryInfo().percentage);
		continue;
	
	} else if (isBatteryBelowRange(config.range, batteryInfo())) {
		sayConnectCharger(batteryInfo());
		continue;
		
	} else if (isBatteryAboveRange(config.range, batteryInfo())) {
		sayDisconnectCharger(batteryInfo())
		continue;
		
	}
}
