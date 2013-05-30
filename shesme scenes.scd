( // all off
[ 'baarmoeder', 'broken', 'chords', 'gedicht', 'humming', 'ikzoekjeniet', 'laughing', 'mumbling', 'notes', 'opnieuw', 'pattern', 'sfr', 'tttt', 'tzu', 'quotes', 'wapentuig', 'words', 'coupler' ].do({ |item| ~shesme[ item ].end });
x.stop;
)


( // 1: climbing
~shesme.mumbling.applyPreset( \low );
~shesme.coupler.applyPreset( \climbing );
~shesme.notes.fade = 0;
~shesme.mumbling.start;
~shesme.coupler.start;
x = {
	~shesme.notes.selection = (86/92).dup;
	~shesme.notes.start;
	0.1.wait;
	~shesme.notes.end;
	~shesme.notes.currentNoteDur.postln;
	(~shesme.notes.currentNoteDur + 7).wait;
	~shesme.notes.selection = [0.25,1];
	~shesme.notes.start;
}.fork;
)


( // 2: handshake
~shesme.coupler.applyPreset( \climbing );
~shesme.mumbling.end;
~shesme.notes.end;
~shesme.tttt.start;
~shesme.coupler.start;
)


( // 3a: talking / silence
~shesme.coupler.end;
~shesme.tttt.end;
)

( // 3b: talking / words
~shesme.notes.selection = [0,0.4];
~shesme.notes.start;
~shesme.words.applyPreset( \all );
~shesme.words.start;
)

 // 3c: talking / words
~shesme.words.applyPreset( \love );

( // 3d: talking / silence again
~shesme.notes.end;
~shesme.words.end;
)


( // 4: open dress
~shesme.notes.end;
~shesme.words.end;
~shesme.broken.amp = 0.2;
~shesme.broken.start;
)


( // 5a: rhythm dance (first) / drop hand
~shesme.coupler.end;
~shesme.mumbling.applyPreset( \rhythm );
~shesme.mumbling.amp = 0.8;
~shesme.broken.end;
~shesme.mumbling.start;
)

( // 5b: walking (first) 
~shesme.coupler.end;
~shesme.broken.start;
~shesme.mumbling.end;
)

( // 5c: rhythm dance (second)
~shesme.coupler.end;
~shesme.mumbling.applyPreset( \rhythm );
~shesme.broken.end;
~shesme.mumbling.start;
)

( // 5d: walking (second)
~shesme.coupler.end;
~shesme.broken.start;
~shesme.mumbling.end;
)

( // 5e: rhythm walking fast switch / dance
~shesme.coupler.applyPreset( \rhythm );
~shesme.coupler.start;
)

( // 5f: touch painting
~shesme.sfr.applyPreset( \rollig );
~shesme.sfr.amp = 0.1;
~shesme.sfr.start;
~shesme.mumbling.amp = 0;
~shesme.broken.amp = 0;
)

( // 5g: release painting
~shesme.sfr.duck = 1;
~shesme.sfr.end;
~shesme.sfr.duck = 0;
~shesme.mumbling.amp = 0.8;
~shesme.broken.amp = 0.2;
)


( // 6a: walking next step
~shesme.coupler.end;
~shesme.mumbling.start;
~shesme.broken.end;
)

// 6b: walking next steps
~shesme.mumbling.speed = 3;

~shesme.mumbling.speed = 2;

( // 6c walk last steps -> wapentuig
~shesme.mumbling.start;
~shesme.wapentuig.end;
~shesme.sfr.end;
x = {
	var start, end, time = 5, res = 0.1, n;
	start = 2;
	end = 0.38;
	n = (time * (1/res)).ceil; 
	n.do({ |i|
		~shesme.mumbling.speed = i.linlin(0,n-1, start, end);
		res.wait;
	});
	~shesme.sfr.applyPreset( \granular );
	~shesme.sfr.amp = 0.35;
	(1/end).wait;
	~shesme.sfr.start;
	0.33.wait;
	~shesme.mumbling.end;
	
	~shesme.wapentuig.amp = 0;
	~shesme.wapentuig.pos = 0;
	~shesme.wapentuig.start;

	200.do({ |i|
		~shesme.wapentuig.mapSet(\amp, i.linlin(0,199,0,0.39) );
		0.1.wait;
	});
	530.do({ |i|
		~shesme.wapentuig.pos = i.linlin(0,999,0,0.97);
		0.08.wait;
	});
	3.wait;
	470.do({ |i|
		i = i + 520;
		~shesme.wapentuig.pos = i.linlin(0,999,0,0.97);
		0.08.wait;
	});

}.fork;
)


( // 7a: prepare dress
~shesme.coupler.end;
~shesme.coupler.applyPreset( \dress );
~shesme.mumbling.applyPreset( \dress );
~shesme.sfr.amp = 0;
~shesme.sfr.applyPreset( \rollig );
)

( // 7b: start dress
~shesme.mumbling.duck = 1;
~shesme.mumbling.start;
~shesme.coupler.start;
)

// 7c: touch human
~shesme.sfr.applyPreset( \sjj );

// 7d: touch painting
~shesme.sfr.applyPreset( \rollig );


(
// 8: start pattern
~shesme.coupler.end;
~shesme.coupler.applyPreset( \pattern );
~shesme.humming.end;
~shesme.sfr.end;
~shesme.pattern.speed = 8;
~shesme.pattern.ratio = 1;
~shesme.pattern.start;
~shesme.coupler.start;
)

(
// 8b: pattern end
{
	~shesme.coupler.end;
	~shesme.pattern.scream = 0;
	20.do({ |i|
		i = i.linlin(0,19,0,1);
		~shesme.pattern.speed = i.linexp(0,1,8,16);
		~shesme.pattern.ratio = i.linexp(0,1,1,4);
		0.1.wait;
	});
	~shesme.pattern.end
}.fork;
)


(
// 9a: laughing
~shesme.laughing.applyPreset( \default );
~shesme.laughing.amp = 0.75;
~shesme.laughing.start;
)

( //9b: laughing end
~shesme.sfr.applyPreset( \dripping );
~shesme.sfr.filter = 1;
~shesme.sfr.amp = 0.1;
~shesme.sfr.start;
~shesme.sfr.filter = 0.7;
{
	var filterEnv, verbEnv, pbrateEnv;
	verbEnv = Env([ 0, 0.66, 1 ], [2,10] );
	filterEnv = Env([0,0,1], [5, 7] );
	pbrateEnv = Env([1,1,4], [3, 9] );
	((12 * 10) + 1).do({ |i|
		i = i * 0.1;
		~shesme.laughing.filter = filterEnv.at(i);
		~shesme.laughing.verb = verbEnv.at(i);
		~shesme.laughing.pbrate = pbrateEnv.at(i);
		0.1.wait;
	});
}.fork;
)

( // 9c: filter down
~shesme.laughing.brassage = 0.75;
x = {
	3.wait;
	
	100.do({ |i|
		~shesme.laughing.amp = i.linlin(0,20,0.75,0.33);
		~shesme.laughing.filter = i.linlin(0,99,1,-0.75);
		~shesme.laughing.pbrate = i.linexp(0,99,4,0.33);
		0.1.wait
	});

}.fork;
)

( // 9d: dripping to back
x = {
	50.do({ |i|
		~shesme.sfr.pan = i.linlin(0,49,[-2,2],[1/3,2/3]);
		0.1.wait
	});
}.fork;
)


( // 10a: mumbling start
~shesme.mumbling.applyPreset( \fragments );
~shesme.mumbling.amp = 0.1;
~shesme.mumbling.start;
~shesme.laughing.filter = -1;
)

( // 10b: quotes start
~shesme.quotes.start;
~shesme.sfr.end;
~shesme.laughing.end;
)

( // 10c: baarmoeder start
~shesme.baarmoeder.amp = 0;
~shesme.baarmoeder.start;
x = { 
	var dur = 60, amp = 0.15;
	var spec = \amp.asSpec;
	amp = spec.unmap( amp );
	(dur * 10).do({ |i|
		~shesme.baarmoeder.amp = spec.map( i.linlin(0, (dur*10)-1, 0, amp ) );
		0.1.wait;
	});
}.fork;
)

// 10d: quotes only "in mijn land"
~shesme.quotes.selection = 4;


( // 11: end
~shesme.mumbling.end;
~shesme.baarmoeder.end;
x = {
	var time;
	time = ~shesme.baarmoeder.currentNoteDur - 
		(Process.elapsedTime - ~shesme.baarmoeder.currentNoteStartedAt);
	"stopping in % seconds\n".postf( time.round(1) );
	(time - 5).wait;
	~shesme.quotes.end;
}.fork;
)


x.stop;