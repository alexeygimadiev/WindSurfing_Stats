using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application as App; 

class WindSurfing_StatsView extends WatchUi.DataField {

    hidden var mValue = "v0.8 20220507";	
    hidden var label = "No GPS signal";
    
	hidden var timerRunning = false;   // did the user press the start button?

	hidden var logger as Logger;
	
    hidden var JibeCount = 0;
    hidden var TurnCount = 0;
    hidden var MinSpeedInAlphaRun = 100;

	//hidden var Points = new[0]; //Here we'll collect Points
    hidden var Lats = new[0];
    hidden var Lons = new[0];
    hidden var Speeds = new[0];
    hidden var Lats10 = new[11]; // 11 points for 10 secs
    hidden var Lons10 = new[11];
    hidden var Ticker10 = new[11];
    hidden var Speeds10 = new[11];
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
        //mValue = "";
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
    	if (lat1 == null){return 0;}
    	if (lat2 == null){return 0;}
    	if (lon1 == null){return 0;}
    	if (lon2 == null){return 0;}
    	if (lat1 > 3.1415) {return 0;}
    	if (lon1 > 3.1415) {return 0;}
    	if (lat2 > 3.1415) {return 0;}
    	if (lon2 > 3.1415) {return 0;}
    	if (lat1 < 0.000001) {return 0;}
    	if (lon1 < 0.000001) {return 0;}
    	if (lat2 < 0.000001) {return 0;}
    	if (lon2 < 0.000001) {return 0;}
    	
    	//if (lat1*lon1*lat2*lon2 == 0) { return 0; }
    	
		var dy = (lat2-lat1);
		var dx = (lon2-lon1);

		var sy = Math.sin(dy / 2);
			sy *= sy;

		var sx = Math.sin(dx / 2);
			sx *= sx;

		var a = sy + Math.cos(lat1) * Math.cos(lat2) * sx;
		
		if (a==1) {
			return 0; // devision by zero in a next statement
		}
		// you'll have to implement atan2
		var c = 2 * Math.atan(Math.sqrt(a)/ Math.sqrt(1-a));

		var R = 6371000.00; // radius of earth in meters
	/*	if (c > 0.05) {
			System.println( "R * c = " + R * c);
			System.println("lat1 = " + lat1 + ", lon1 = " + lon1 + ", lat2 = " + lat2 + ", lon2 = " + lon2);
		}
	*/
		return R * c;
		
	}
	
    
    
    function compute(info) {
		var lat, lon, latDegrees, lonDegrees; 
		var curSpeed;
		var KnotsOrKMH = App.getApp().getProperty("Display_Knots_or_KMH");
			//System.println("KnotsOrKMH: " + KnotsOrKMH);
		var multiplier;
		if (KnotsOrKMH ==1) {multiplier = 1;} else {multiplier = 0.539957;}
		var ulabel;
		if (KnotsOrKMH ==1) {ulabel = "km/h";} else {ulabel = "kts";}
//		if ((info.currentLocation != null) && (info.currentLocation.toDegrees()[0].toDouble() < 179))
//		{
			
			
			
//			System.println("Location: " + info.currentLocation.toDegrees());
//			System.println("Location: " + info.currentLocation.toRadians());
//			System.println("Points size: " + Lats.size() + ":" + Lons.size());
//			System.println("CurrentDist500: " + CurrentDist500 + ", ChkDst" + chkDist );
//			System.println("Insiderun: " + InsideRun);
//			System.println("MinSpeedInAlphaRun: " + MinSpeedInAlphaRun);			
//			System.println("currentSpeed: " + info.currentSpeed);
			if (info.currentLocation != null) 
			{
				lat = info.currentLocation.toRadians()[0].toDouble();
				lon = info.currentLocation.toRadians()[1].toDouble();
				latDegrees = info.currentLocation.toDegrees()[0].toDouble() ;
				lonDegrees =  info.currentLocation.toDegrees()[1].toDouble() ;
				curSpeed = info.currentSpeed;
			}
			else
			{
				lat = 0;
				lon = 0;
				latDegrees = 0;
				lonDegrees = 0;
				curSpeed = 0;
			}
			if (curSpeed == null) {curSpeed = 0;}
			/*
			System.println("T," + ticker 
									+ "," + latDegrees 
									+ "," + lonDegrees
									+ ",		" + info.currentSpeed * 3.6 // to kmh
									+ "," + CurrentDist500 
									+ "," + chkDist 
									//+ "," + Lats.size()
									//+"," + info.currentLocationAccuracy 
									//+"," + i10
									//+"," + j10
						   );
				*/		   
			
/*		}
		else {
 		    label = "No GPS signal";
 			mValue = "v0.4 20210804";	
 			if (TurnCount > 0) {mValue = JibeCount.toString() + "/" + TurnCount.toString() + " jbs";}
			return; 
		} 
*/

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
 		Lats10[i10] = lat; Lons10[i10] = lon; Ticker10[i10] = ticker;

//		if (Lats10[j10] !=null ) { //top5x10 analysis starts when we have more than 10 points
			    var cur10; 
			    var tickerdiff=10000;
			    
			    if (Ticker10[j10] !=null){
				 tickerdiff = Ticker10[i10]-Ticker10[j10];}
				 
				 cur10 = 3.6 * Geodetic_distance_rad(Lats10[i10],Lons10[i10], Lats10[j10], Lons10[j10]) / tickerdiff ;
				 if (cur10>b10) {b10 = cur10;}
				
				/*
				 System.println("cur10 = " + cur10.format("%.0f") 
				 			+ " b10 = " + b10.format("%.0f") 
				 			+ " ticker = " + ticker
				 			//+ "
				 			//+ " i10 = " + i10.format("%.0f")
				 			//+ " j10 = " + j10.format("%.0f")
				 			+ " tickerdiff = " + tickerdiff.format("%.0f")
				 			//+ " Inside10Run = " + Inside10Run.format("%.0f")
				 			+ " Lats10[i10] = " + Lats10[i10]
				 			+ " Lons10[i10] = " + Lons10[i10]
				 			+ " Lats10[j10] = " + Lats10[j10]
				 			+ " Lons10[j10] = " + Lons10[j10]
				 );	
				 */	
				
				if (Inside10Run == 0) { //run not started
					if (curSpeed > 3) {Inside10Run = 1;} //start run
					else {b10 = 0;
						Lats10[0]=null;Lats10[1]=null;Lats10[2]=null;Lats10[3]=null;Lats10[4]=null;Lats10[5]=null;
						Lats10[6]=null;Lats10[7]=null;Lats10[8]=null;Lats10[9]=null;Lats10[10]=null;
					
					} ///reset b10
				}	 
				else if(Inside10Run ==1) { //run started
					if ((curSpeed <3 ) || (curSpeed * 3.6 < b10 * 0.5) ){
							Inside10Run = 0; //to slow, end run

							if		(b10 > b101) { b105=b104;b104=b103;b103=b102;b102=b101;b101=b10; }
							else if (b10 > b102) { b105=b104;b104=b103;b103=b102;b102=b10; }
							else if (b10 > b103) { b105=b104;b104=b103;b103=b10; }
							else if (b10 > b104) { b105=b104;b104=b10; }
							else if (b10 > b105) { b105=b10; } 
							b10 = 0; ///reset b10
							Lats10[0]=null;Lats10[1]=null;Lats10[2]=null;Lats10[3]=null;Lats10[4]=null;Lats10[5]=null;
							Lats10[6]=null;Lats10[7]=null;Lats10[8]=null;Lats10[9]=null;Lats10[10]=null;
					} ///info.currentSpeed < 3
				} //inside10Run ==1
//			}//(Lats10[j10] !=null){ 


		
		/// start Alpha analysis
 		var dDist = 0; 
	 	Lats.add(lat); Lons.add(lon); //for alphas
	 	Speeds.add(curSpeed);

 			
 			//Alpha analysis
 		if(Lats.size() > 1){ dDist = Geodetic_distance_rad(lat,lon, Lats[Lats.size()-2], Lons[Lons.size()-2]); }
			
	 		
	 	//	if( info.currentSpeed < MinSpeedInAlphaRun ) { MinSpeedInAlphaRun = info.currentSpeed;}
	
 			while
 			(
				 (Lats.size()> 110) 
			 ||
			 	 (CurrentDist500 + dDist > 500) )
 			 {
 			 	//System.println("Lats.size() = " + Lats.size() + " Lons.size() = " + Lons.size() + " CurrentDist500 = " + CurrentDist500);
				CurrentDist500 -= Geodetic_distance_rad(Lats[0], Lons[0], Lats[1], Lons[1]);
				
				if (CurrentDist500<0) {CurrentDist500 = 0;}
				Lats = Lats.slice(1,null) ;
				Lons = Lons.slice(1,null) ;
				Speeds = Speeds.slice(1,null) ;
			}
			
			CurrentDist500+=dDist;
			
			chkDist = Geodetic_distance_rad(Lats[0],Lons[0], Lats[Lats.size()-1], Lons[Lons.size()-1]);			
			//if (CurrentDist500 > 150) {InsideRun = 1;} //200 meters run, jibe is possible
	
			//finally, check distance between startpoint and endpoint
			if (( CurrentDist500 > 200 ) && (chkDist < 55) && (chkDist) > 0 && (dDist > 0))
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
 		    label = "Top5x10, " + ulabel;
 		    if(Inside10Run == 1) {label = label + " (run:" + (b10 * multiplier).format("%.0f") + "):";}
            mValue = (b101 * multiplier).format("%.0f") + " " 
            		+ (b102 * multiplier).format("%.0f") + " " 
            		+ (b103 * multiplier).format("%.0f") + " "
            		+ (b104 * multiplier).format("%.0f") + " "
            		+ (b105 * multiplier).format("%.0f") ;
        } else if (timerSlot <= 2 * screenDelay -1) {
            label = "Top5 @500, " + ulabel + ":" ;
            mValue = (ba1 * multiplier).format("%.0f") + " " 
            		+ (ba2 * multiplier).format("%.0f") + " "
            		+ (ba3 * multiplier).format("%.0f") + " " 
            		+ (ba4 * multiplier).format("%.0f") + " " 
            		+ (ba5 * multiplier).format("%.0f") ;
        } else if (timerSlot <= 3 * screenDelay -1) {
            label = JibeCount.toString() + "/" + TurnCount.toString() + " jbs, last @500:";
            mValue = (LastAlphaSpeed * multiplier).format("%.2f") ;
        } else if (timerSlot  == 101) {
        	label = "CurSpeed, " + ulabel + ":";
        	mValue = (curSpeed * 3.6 * multiplier).format("%.2f");
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
