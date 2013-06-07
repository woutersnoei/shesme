NanoKONTROL();

NanoKONTROL.sliders[0][0].action = { |sl| q.verb.amp = \amp.asSpec.map( sl.value ) };

NanoKONTROL.sliders[0][1].action = { |sl| q.verb.dry = \amp.asSpec.map( sl.value ) };

NanoKONTROL.knobs[0][0].action = { |sl| q.verb.extra = sl.value; };

NanoKONTROL.knobs[0][1].action = { |sl| q.verb.quad = sl.value; };

NanoKONTROL.sliders[0][2].action = { |sl| 
	~shesme.dataNetwork.vals[ \d2 ] = \amp.asSpec.map( sl.value ) 
};

NanoKONTROL.sliders[0][3].action = { |sl| 
	~shesme.mumbling.filter = sl.value.linlin(0,1,-1,1);
};

NanoKONTROL.buttons[0][3].action = { |sl| 
	if( ~shesme.mumbling.active.not ) { ~shesme.mumbling.start };
	if( ~shesme.broken.active ) { ~shesme.broken.end };
};

NanoKONTROL.buttons[0][3+9].action = { |sl| 
	if( ~shesme.broken.active.not ) { ~shesme.broken.start };
	if( ~shesme.mumbling.active ) { ~shesme.mumbling.end };
};

NanoKONTROL.sliders[0][4].action = { |sl| 
	~shesme.pattern.ratio = sl.value.linexp(0,1,1,4);
};

NanoKONTROL.buttons[0][4].action = { |sl| 
	~shesme.pattern.scream = 1;
};

NanoKONTROL.buttons[0][4+9].action = { |sl| 
	~shesme.pattern.scream = 0;
};

NanoKONTROL.sliders[0][7].action = { |sl| 
	~shesme.sfr.convolve = sl.value;
};


NanoKONTROL.buttons[0][8].action = { |bt| 
	switch( bt.value.asInt, 
		1, {
			 // 5f: touch painting
			 if( ~shesme.sfr.active.not ) {
				~shesme.sfr.start;
			};
			~shesme.sfr.amp = \amp.asSpec.map( NanoKONTROL.sliders[0][8].value );
			~shesme.sfr.start;
			~shesme.mumbling.amp = 0;
			~shesme.broken.amp = 0;
		},
		0, {
			// 5g: release painting
			~shesme.sfr.duck = 1;
			~shesme.sfr.amp = 0;
			~shesme.sfr.duck = 0;
			~shesme.mumbling.amp = 0.8;
			~shesme.broken.amp = 0.2;
		}
	);
};

NanoKONTROL.sliders[0][8].action = { |sl|
	if( ~shesme.sfr.amp > 0 ) {
		~shesme.sfr.amp = \amp.asSpec.map( sl.value );
	};
};

NanoKONTROL.knobs[0][8].action = { |kn| 
	var env1, env2;
	env1 = Env([-2, -0.16,0.832], [0.25,0.75] );
	env2 = Env([2, -0.16,0.832], [0.25,0.75] );
	~shesme.sfr.pan = [ env1.at( kn.value ), env2.at( kn.value ) ];
};

NanoKONTROL.buttons[0][8].action = { |bt| 
	switch( bt.value.asInt, 
		1, {
			 // 5f: touch painting
			 if( ~shesme.sfr.active.not ) {
				~shesme.sfr.start;
			};
			~shesme.sfr.amp = \amp.asSpec.map( NanoKONTROL.sliders[0][8].value );
			if( ~shesme.mumbling.speed < 10 ) { ~shesme.mumbling.amp = 0; };
			~shesme.broken.amp = 0;
		},
		0, {
			// 5g: release painting
			~shesme.sfr.duck = 1;
			~shesme.sfr.amp = 0;
			~shesme.sfr.duck = 0;
			if( ~shesme.mumbling.speed < 10 ) { ~shesme.mumbling.amp = 0.8; };
			~shesme.broken.amp = 0.2;
		}
	);
};

NanoKONTROL.buttons[0][17].action = { |bt|
	if( bt.value.asInt == 1 ) {
		if( ~shesme.sfr.overlap.round(1) == 8 ) {
			~shesme.sfr.applyPreset( \rollig );
		} {
			~shesme.sfr.applyPreset( \sjj );
		};
	};
};

NanoKONTROL.buttons[0][22].action = { |bt|
	if( bt.value > 0.5 ) { 
		 // all off
		[ 'baarmoeder', 'broken', 'chords', 'gedicht', 'humming', 'ikzoekjeniet', 'laughing', 'mumbling', 'notes', 'opnieuw', 'pattern', 'sfr', 'tttt', 'tzu', 'quotes', 'wapentuig', 'words', 'coupler' ].do({ |item| ~shesme[ item ].end });
		x.do(_.stop); x = nil;
		};
};


