using Toybox.WatchUi;
using Toybox.Graphics;

class WindSurfing_StatsView extends WatchUi.DataField {

    hidden var mValue;
    hidden var label = "Total";
    
	hidden var timerRunning = false;   // did the user press the start button?

    hidden var JibeCount = 0;
    hidden var TurnCount = 0;
    hidden var MinSpeedInAlphaRun = 100;

	//hidden var Points = new[0]; //Here we'll collect Points
    hidden var Lats = new[0];
    hidden var Lons = new[0];
    hidden var Speeds = new[0];
    hidden var Lats10 = new[11]; // 11 points for 10 secs
    hidden var Lons10 = new[11];
    hidden var chkDist = 0;
    hidden var dLimit = 1000;
    hidden var i10 = 0, j10 = 9; 
    //hidden var dDs = new[0];

    hidden var CurrentDist500 = 0;
    //hidden var StartPoint = 0;
    hidden var LastAlphaSpeed = 0;

    hidden var ba1 = 0;
    hidden var ba2 = 0;
    hidden var ba3 = 0;
    hidden var ba4 = 0;
    hidden var ba5 = 0;
    hidden var InsideRun = 0;
     
	hidden var b101 = 0;
	hidden var b102 = 0;
	hidden var b103 = 0;
	hidden var b104 = 0;
	hidden var b105 = 0;
	hidden var b10  = 0;

	hidden var Inside10Run = 0;

	hidden var ticker = 0;         // amount of seconds the timer is in the "active" state
 
    function initialize() {
        DataField.initialize();
        mValue = "";
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }

        View.findDrawableById("label").setText(Rez.Strings.label);
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    
    
    function Geodetic_distance_rad(lat1, lon1, lat2, lon2) {
		var dy = (lat2-lat1);
		var dx = (lon2-lon1);

		var sy = Math.sin(dy / 2);
			sy *= sy;

		var sx = Math.sin(dx / 2);
			sx *= sx;

		var a = sy + Math.cos(lat1) * Math.cos(lat2) * sx;
		// you'll have to implement atan2
		var c = 2 * Math.atan(Math.sqrt(a)/ Math.sqrt(1-a));

		var R = 6371000.00; // radius of earth in meters
		return R * c;
	}
	
    
    
    function compute(info) {
		var lat, lon;
		if ((info.currentLocation != null) && (info.currentLocation.toDegrees()[0].toFloat() < 179))
		{
			
			
			
//			System.println("Location: " + info.currentLocation.toDegrees());
//			System.println("Location: " + info.currentLocation.toRadians());
//			System.println("Points size: " + Lats.size() + ":" + Lons.size());
//			System.println("CurrentDist500: " + CurrentDist500 + ", ChkDst" + chkDist );
//			System.println("Insiderun: " + InsideRun);
//			System.println("MinSpeedInAlphaRun: " + MinSpeedInAlphaRun);			
//			System.println("currentSpeed: " + info.currentSpeed);
			
			lat = info.currentLocation.toRadians()[0].toFloat();
			lon = info.currentLocation.toRadians()[1].toFloat();
			/*
			System.println("T," + ticker 
									+ "," + info.currentLocation.toDegrees()[0].toFloat() 
									+ "," + info.currentLocation.toDegrees()[1].toFloat() 
									+ "," + info.currentSpeed
									+ "," + CurrentDist500 
									+ "," + chkDist 
						   );
						   */
			
		}
		else {
 		    label = "No GPS signal";
 			mValue = "v0.3 20200922";	
 			if (TurnCount > 0) {mValue = JibeCount.toString() + "/" + TurnCount.toString() + " jbs";}
			return; 
		} 

        if (timerRunning) {  ticker++;  }  else     { 	return; }

		var screenDelay = 3; //secs for screen
		var screensCount = 3; 
		if (ba1 == 0) {screensCount = 1;}
			//	else if (ba5 == 0) {screensCount = 2;}
			else {screensCount = 3;}
		
       
        var timerSlot = (ticker % (screenDelay * screensCount));  // modulo the number of fields (4) * number of seconds to show the field (5)
		if (b101==0) {timerSlot = 101;} // no records to show

		/* for top5x10 */
 		i10 = (i10+1) % 11 ; j10 = (i10+1) % 11; 
 		Lats10[i10] = lat; Lons10[i10] = lon; 

		if (Lats10[j10] !=null ) { //top5x10 analysis starts when we have more than 10 points
			    var cur10;
				 cur10 = 3.6 * Geodetic_distance_rad(Lats10[i10],Lons10[i10], Lats10[j10], Lons10[j10]) / 10 ;
				 if (cur10>b10) {b10 = cur10;}
				 
				if (Inside10Run == 0) { //run not started
					if (info.currentSpeed > 5) {Inside10Run = 1;} //start run
				}
				else if(Inside10Run ==1) { //run started
					if (info.currentSpeed <5) {
							Inside10Run = 0; //to slow, end run

							if		(b10 > b101) { b105=b104;b104=b103;b103=b102;b102=b101;b101=b10; }
							else if (b10 > b102) { b105=b104;b104=b103;b103=b102;b102=b10; }
							else if (b10 > b103) { b105=b104;b104=b103;b103=b10; }
							else if (b10 > b104) { b105=b104;b104=b10; }
							else if (b10 > b105) { b105=b10; } 
							b10 = 0; ///reset b10
					} ///info.currentSpeed < 5
				} //inside10Run ==1
			}//(Lats10[j10] !=null){ 


		
		/// start Alpha analysis
 		var dDist = 0; 
	 	Lats.add(lat); Lons.add(lon); //for alphas
	 	Speeds.add(info.currentSpeed);

 			
 			//Alpha analysis
 		if(Lats.size() > 1){ dDist = Geodetic_distance_rad(lat,lon, Lats[Lats.size()-2], Lons[Lons.size()-2]); }
			
	 		
	 	//	if( info.currentSpeed < MinSpeedInAlphaRun ) { MinSpeedInAlphaRun = info.currentSpeed;}
	
 			while
 			(
				 (Lats.size()> 180) 
			 ||
			 	 (CurrentDist500 + dDist > 500) )
 			 {
				CurrentDist500 -= Geodetic_distance_rad(Lats[0], Lons[0], Lats[1], Lons[1]);
				Lats = Lats.slice(1,null) ;
				Lons = Lons.slice(1,null) ;
				Speeds = Speeds.slice(1,null) ;
			}
			
			CurrentDist500+=dDist;
			
			chkDist = Geodetic_distance_rad(Lats[0],Lons[0], Lats[Lats.size()-1], Lons[Lons.size()-1]);			
			//if (CurrentDist500 > 150) {InsideRun = 1;} //200 meters run, jibe is possible
	
			//finally, check distance between startpoint and endpoint
			if (( CurrentDist500 > 200 ) && (chkDist < 55))
				{ // 50 meters for jibe
					MinSpeedInAlphaRun = 1000;
					for( var k = 0; k< Speeds.size(); k++){  if (Speeds[k]<MinSpeedInAlphaRun) { MinSpeedInAlphaRun = Speeds[k];	} 	}
					
					//System.println("We've got the Jibe!!!,"+ticker+", MinSpeedInAlphaRun: kmh, " + 3.6 * MinSpeedInAlphaRun);
										
					if(MinSpeedInAlphaRun > 3) { //condition for planing jibe
							JibeCount++; }
					
					TurnCount++;
					
					LastAlphaSpeed = 3.6 * CurrentDist500 / (Lats.size() - 1); //-- Lats.size() for seconds count
				
					if		(LastAlphaSpeed > ba1)  { ba5 = ba4;ba4 = ba3;ba3 = ba2; ba2 = ba1; ba1 = LastAlphaSpeed;}
					else if (LastAlphaSpeed > ba2) 	{ ba5 = ba4;ba4 = ba3;ba3 = ba2; ba2 = LastAlphaSpeed;}
					else if (LastAlphaSpeed > ba3) 	{ ba5 = ba4;ba4 = ba3;ba3 = LastAlphaSpeed; }
					else if (LastAlphaSpeed > ba4) 	{ ba5 = ba4;ba4 = LastAlphaSpeed;}
					else if (LastAlphaSpeed > ba5)  { ba5 = LastAlphaSpeed;	}
					
					//clean last 60% of the run
					dLimit = CurrentDist500 * 0.4;
					while 	 (CurrentDist500 > dLimit) 
 			 		//for( var k = 0; k< 10; k++)
 			 		{
							CurrentDist500 -= Geodetic_distance_rad(Lats[0], Lons[0], Lats[1], Lons[1]);
							Lats = Lats.slice(1,null) ;
							Lons = Lons.slice(1,null) ;
							Speeds = Speeds.slice(1,null) ;
					}
					
					} ///got the jibe

			

	////Set labels 		
 		if (timerSlot <= screenDelay - 1) {  // first time slot
 		    label = "Top5x10 (run:" + b10.format("%.0f") + "):";
            mValue = b101.format("%.0f") + " " + b102.format("%.0f") + " " + b103.format("%.0f") + " " + b104.format("%.0f") + " " + b105.format("%.0f") ;
        } else if (timerSlot <= 2 * screenDelay -1) {
            label = "Top5 @500:" ;
            mValue = ba1.format("%.0f") + " " + ba2.format("%.0f") + " " + ba3.format("%.0f") + " " + ba4.format("%.0f") + " " + ba5.format("%.0f") ;
        } else if (timerSlot <= 3 * screenDelay -1) {
            label = JibeCount.toString() + "/" + TurnCount.toString() + " jbs, last @500:";
            mValue = LastAlphaSpeed.format("%.2f") ;
        } else if (timerSlot  == 101) {
        	label = "No recs, curSpeed:";
        	mValue = info.currentSpeed.format("%.2f");
        }
        
        else {
             mValue= "";
         	label = "???";
        }
 
      
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and value
        var value = View.findDrawableById("value");
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
        }
        value.setText(mValue);

		// label also needs to be updated regularly
        View.findDrawableById("label").setText(label);
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }
    
    //! Timer transitions from stopped to running state
    function onTimerStart() {
        if (!timerRunning) {
            var activityMonitorInfo = Toybox.ActivityMonitor.getInfo();
//            stepsNonActive = activityMonitorInfo.steps - stepsRecorded;
            timerRunning = true;
        }
    }
 
    //! Timer transitions from running to stopped state
    function onTimerStop() {
        timerRunning = false;
        ticker = 0;
    }
 
    //! Activity is ended
    function onTimerReset() {
  //      stepsRecorded = 0;
    }

	

}
