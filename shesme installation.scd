~shesme = ~shesme ? EM();

~shesme = ~shesme ? EM();

~shesme.installation = ~shesme.installation ? EM();

~shesme.names = ~shesme.names ++ [ \installation ];

/*
~shesme.installation.end;
~shesme.installation.endSound;

~shesme.installation.start;

~shesme.doAfterLoad;
*/

~shesme.doAfterLoad = { |evt|
	~shesme.makeWindow;
	~shesme.speakerCorrect.start;
	q.verb.amp = 0.5;
	q.verb.dry = 0.2;
	q.verb.quad = 1;
	q.verb.extra = 0;
	~shesme.verb.start;
	~shesme.words.waitTime = 30;
	~shesme.words.amp = 0.15;
	~shesme.quotes.applyPreset( \long_waitforactive );
	~shesme.quotes.amp = 0.3;
	~shesme.notes.amp = 0.05;
	~shesme.chords.amp = 0.05;
	~shesme.laughing.amp = 0.4;
	~shesme.tttt.amp = 0.03;
	~shesme.baarmoeder.amp = 0.05;
	
	~shesme.installation.start;
	
	//~shesme.chords.start;
	//~shesme.notes.start;
};

~shesme.installation.start = { |evt|
	evt.startTasks;
	evt.startBaarMumbling;
	~shesme.quotes.start;
	~shesme.words.start;
	evt.active = true;
};

~shesme.installation.end = { |evt|
	evt.endTasks;
	evt.endBaarMumbling;
	~shesme.quotes.end( true );
	[ 
		'baarmoeder', 'broken', 'chords', 'gedicht', 
		'humming', 'laughing', 'mumbling', 'notes', 
		'pattern', 'sfr', 'tttt', 'wapentuig', 'words' 
	].do({ |item|
		~shesme[ item ].end( );
	});
	evt.active = false;
};

~shesme.installation.startTasks = { |evt|
	evt.endTasks;
	evt.laughing = { // laughing
		var lastPreset = 2;	
		var presets = [ \default, \chatter, \birdlike, \lowish ];
		loop {
			if( 0.33.coin ) {
				lastPreset = presets.size.xrand( lastPreset );
				~shesme.laughing.applyPreset( presets[ lastPreset ] );
				if( ~shesme.laughing.active != true ) {
					~shesme.laughing.start;
				};
				(5 rrand: 30).wait;
				~shesme.laughing.end;
			} {
				~shesme.laughing.end;
			};
			(20 rrand: 40).wait;
		};
	}.fork;

	evt.sfr = { // sfr
		var lastPreset = 2;
		var presets = [ 'rrr', 'clicks', 'sjj', 'tttt', 'rollig', 'granular', 'slow ffs', 'dripping' ];
		loop {
			if( 0.4.coin ) {
				lastPreset = presets.size.xrand( lastPreset );
				~shesme.sfr.applyPreset( presets[ lastPreset ] );
				if( ~shesme.sfr.active != true ) {
					~shesme.sfr.start;
				};
			} {
				~shesme.sfr.end(4);
			};
			(20 rrand: 30).wait;
		
		};
	}.fork;
	
	evt.notes = { // notes
		loop {
			if( 0.5.coin ) {
				if( ~shesme.notes.active != true ) {
					~shesme.notes.start;
				};
			} {
				~shesme.notes.end;
			};
			(40 rrand: 60).wait;
		
		};
	}.fork;

	evt.chords = {	 // chords
		var lastPreset = 2;
		var brokenPresets = [ \default, \shifted, \low ];
		var chordPresets = [ \default, \hi, \low ];
		loop {
			if( 0.5.coin ) {
				if( 0.5.coin ) {
					lastPreset = chordPresets.size.xrand( lastPreset );
					~shesme.chords.applyPreset( chordPresets[ lastPreset ] );
					if( ~shesme.baarmoeder.active != true && { ~shesme.mumbling.active != true } ) {
						if( ~shesme.chords.active != true ) {
							~shesme.chords.start;
						};
					} {
						~shesme.chords.end;
					};
					~shesme.broken.end;
				} {
					lastPreset = brokenPresets.size.xrand( lastPreset );
					~shesme.broken.applyPreset( brokenPresets[ lastPreset ] );
					if( ~shesme.broken.active != true ) {
						~shesme.broken.start;
					};
					~shesme.chords.end;
				};
			} {
				~shesme.chords.end;
				~shesme.broken.end;
			};
			(40 rrand: 60).wait;
		
		};
	}.fork;

	evt.tttt =  {
		loop { // tttt
			if( 0.4.coin ) {
				if( ~shesme.tttt.active != true) {
					~shesme.tttt.start;
				};
			} {
				~shesme.tttt.end;
			};
			(10 rrand: 80).wait;
		
		};
	}.fork;
};

~shesme.installation.endTasks = { |evt|
	[ \laughing, \sfr, \chords, \notes, \tttt ].do({ |item| evt[ item ].stop });
};

~shesme.installation.endSound = { |evt|
	[ \broken, \chords, \laughing, \sfr, \tttt ].do({ |item| ~shesme[ item ].end });
	~shesme.notes.endAll;
};

~shesme.installation.startBaarMumbling = { |evt|
	evt.endBaarMumbling;
	evt.baarMumbling = {
		loop {
			(((60 * 5) * 0.75) rrand: ((60 * 5) * 1.25)).wait;
			evt.startMumbling;
			(((60 * 5) * 0.75) rrand: ((60 * 5) * 1.25)).wait;
			evt.startBaarmoeder;
		};
	}.fork;
};

~shesme.installation.endBaarMumbling = { |evt|
	evt.baarMumbling.stop;
	evt.endMumbling;
	evt.endBaarmoeder;
};

(
~shesme.installation.startMumbling = { |evt|
	evt.endTasks;
	evt.endSound;
	~shesme.mumbling.speed = 5;
	~shesme.mumbling.verb = 0;
	~shesme.mumbling.amp = 0.75;
	~shesme.mumbling.start;
	evt.mumbling.stop;
	evt.mumbling = {
		2.wait;
		1.do {
			2.wait;
			100.do({ |i|
				~shesme.mumbling.speed = i.linexp(0,99,5,200);
				(6/100).wait;
			});
			100.do({ |i|
				~shesme.mumbling.speed = i.linexp(0,99,200,2);
				(6/100).wait;
			});
		};
		1.do {
			4.wait;
			100.do({ |i|
				~shesme.mumbling.speed = i.linexp(0,99,2,200);
				~shesme.mumbling.verb = i.linlin(0,99,0,1);
				(7/100).wait;
			});
			evt.startTasks;
			100.do({ |i|
				~shesme.mumbling.speed = i.linexp(0,99,200,5);
				(7/100).wait;
			});
			100.do({ |i|
				~shesme.mumbling.speed = i.linlin(0,99,5,0);
				(15/100).wait;
			});
		};
		2.wait;
		~shesme.mumbling.end;
	}.fork;
};

~shesme.installation.endMumbling = { |evt|
	evt.mumbling.stop;
	~shesme.mumbling.end;
};
);

(
~shesme.installation.startBaarmoeder = { |evt|
	evt.endTasks;
	[ \broken, \chords, \laughing, \notes, \sfr, \tttt ].do({ |item| 		~shesme[ item ].end 
	});
	evt.baarmoeder.stop;
	evt.baarmoeder = {
		10.wait;
		~shesme.baarmoeder.start;
		80.wait;
		evt.startTasks;
		20.wait;
		~shesme.baarmoeder.end;
	}.fork;
};

~shesme.installation.endBaarmoeder = { |evt|
	evt.baarmoeder.stop;
	~shesme.baarmoeder.end( true );
};
);


/*

~shesme.installation.start;
~shesme.installation.end;
~shesme.installation.endAll;

*/