(
~shesme = ~shesme ? EM();

~shesme.notes = ~shesme.notes ? EM();

~shesme.notes.specs = OEM();

~shesme.notes.currentNoteDur = 0;
~shesme.notes.currentNoteStartedAt = 0;

[ \amp, 0.1, \amp.asSpec, \filter, 0, [-1,1,\lin,0,0].asSpec, \fade, 0, [0,1].asSpec, \selection, [0,1], [0,1].asSpec.asRangeSpec ].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.notes[ key ] = value;
	~shesme.notes[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.notes.specs[ key.asGetter ] = spec;
});

~shesme.notes[ \selection_ ] = nil;

~shesme.notes.loadBuffers = { |evt, action|
	{
		var cond;
		cond = Condition( false );
		evt.buffers = [ 
			"samples/low notes/*.wav",
			"samples/midhigh notes/*.wav",
			"samples/high notes/*.wav"
		].collect({ |item|
			(thisProcess.nowExecutingPath.dirname.dirname +/+ item).pathMatch
		}).flatten(1).collect({ |item|
			var buf;
			buf = Buffer.read(s, item, action: { cond.test = true; cond.signal });
			cond.wait;
			cond.test = false;
			"\t%: %\n".postf( buf.bufnum, buf.path.dirname.basename +/+ buf.path.basename );
			buf;
		});
		action.value;
	}.fork;	
};

/*
~shesme.notes.loadBuffers;
*/

(
SynthDef( "shesme_note", { |bufnum = 0, rate = 1, filter = 0, gain = 1, amp = 0.1, pan = 0, gate = 1, fade = 0|
	var sig;
	var fadeIn, fadeOut;
	fadeIn = Rand(0,1);
	fadeOut = 1-fadeIn;
	sig = PlayBuf.ar( 1, bufnum, rate, doneAction: 2 );
	sig = BLowCut.ar( sig, filter.clip(0,1).varlag(Rand(3, 5)).linexp(0,1,20,5000,\minmax), 3 );
	sig = BHiCut.ar( sig, filter.clip(-1,0).varlag(Rand(3, 5)).linexp(-1,0,300,20000,\minmax),3 );
	sig = sig * amp * gain;
	sig = sig * Env([0,1,1,0], (BufDur.kr(bufnum) / rate) * [fadeIn*fade,1-fade,fadeOut*fade]).kr;
	Out.ar( 0, RoundPan.ar( 6, sig, pan ) * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.notes.start = { |evt|
	evt.end;
	evt.task = {
		var index = 0;
		var rate;
		var freqIndex = 0;
		var min, max;
		loop {
			#min, max = (evt.selection * (evt.freqSortedIndices.size -1)).round(1);
			if( max > (evt.freqSortedIndices.size -1) ) {
				max = (evt.freqSortedIndices.size -1);
				if( min >= max ) { min = max - 1 };
			} {
				if( min >= max ) { max = min + 1 };
			};
			freqIndex = (max - min).asInt.xrand(freqIndex - min) + min;
			index = evt.freqSortedIndices[ freqIndex ];
			rate = (evt.freqs[ index ].cpsmidi.round(1).midicps * (1.rand2.midiratio) ) 
						/ evt.freqs[ index ];
			evt.synths = evt.synths.add( 
				Synth( "shesme_note", [ 
					\bufnum, evt.buffers[index], 
					\rate, rate,
					\pan, (-1.0 rrand: 1.0),
					\fade, evt.fade ? 0,
					\gain,  1 / (evt.peaks[ index ] / evt.peaks.mean),
					\amp, evt.amp,
					\filter, evt.filter ? 0,
				] ).freeAction_({ |synth|
					 evt.synths.remove( synth );
				});
			);
			evt.currentNoteDur = evt.buffers[index].duration / rate;
			evt.currentNoteStartedAt = Process.elapsedTime;
			(2.0 rrand: 16.0).wait;
		};
	}.fork;
	evt.active = true;
};

~shesme.notes.end = { |evt|
	evt.task.stop;
	evt.active = false;
};

~shesme.notes.endAll = { |evt|
	evt.end;
	evt.synths.do(_.release);
};

(
~shesme.notes.freqs = [ 219.02687072754, 225.7346496582, 184.53628540039, 245.15466308594, 203.73629760742, 222.35473632812, 198.00444030762, 172.77813720703, 160.67652893066, 222.81889343262, 195.16038513184, 209.80244445801, 229.69987487793, 170.63356018066, 271.91952514648, 325.84085083008, 202.09211730957, 224.34912109375, 211.83322143555, 193.57633972168, 163.21849060059, 170.83335876465, 174.96678161621, 179.65646362305, 196.07621765137, 181.14038085938, 171.89540100098, 194.19169616699, 208.31672668457, 208.41586303711, 287.46130371094, 265.53295898438, 187.78530883789, 198.935546875, 383.42984008789, 347.80480957031, 429.70532226562, 484.67413330078, 388.14572143555, 284.50787353516, 339.65005493164, 541.28460693359, 509.91690063477, 458.50823974609, 509.59429931641, 534.41174316406, 618.14837646484, 662.72869873047, 341.46063232422, 312.1796875, 372.99353027344, 388.85595703125, 432.82949829102, 462.55816650391, 346.03695678711, 510.68893432617, 419.75967407227, 375.28631591797, 490.05661010742, 466.94836425781, 545.75769042969, 490.16848754883, 547.43096923828, 554.03338623047, 582.10321044922, 428.16955566406, 438.01809692383, 437.55563354492, 452.32308959961, 468.33169555664, 438.78457641602, 512.02825927734, 491.82797241211, 583.33099365234, 391.50802612305, 406.31936645508, 774.80706787109, 702.78369140625, 735.34545898438, 686.35223388672, 729.0849609375, 768.14770507812, 816.37847900391, 846.31585693359, 1134.1580810547, 895.51812744141, 1006.28125, 800.63323974609, 852.50164794922, 725.1201171875, 660.37048339844, 936.95269775391, 806.54132080078 ];

~shesme.notes.freqSortedIndices = [ ~shesme.notes.freqs, (..~shesme.notes.freqs.size-1) ]
	.flop.sort({ |a,b| a[0] <= b[0] }).flop[1];
);

(
~shesme.notes.peaks = [ 0.34569823741913, 0.27082741260529, 0.25511968135834, 0.37908232212067, 0.25808084011078, 0.36236071586609, 0.40666198730469, 0.28363966941833, 0.27519309520721, 0.17068779468536, 0.30887126922607, 0.23742830753326, 0.46452081203461, 0.22679567337036, 0.31041657924652, 0.43353402614594, 0.28098356723785, 0.26093828678131, 0.19861936569214, 0.16362071037292, 0.11965489387512, 0.26240372657776, 0.31652748584747, 0.38093209266663, 0.35037302970886, 0.42208099365234, 0.34636604785919, 0.44932925701141, 0.39296221733093, 0.2492139339447, 0.39685392379761, 0.26558125019073, 0.2854460477829, 0.26936161518097, 0.32306718826294, 0.35221362113953, 0.42920017242432, 0.56143414974213, 0.3264946937561, 0.30318105220795, 0.37389183044434, 0.53588318824768, 0.47992372512817, 0.48761916160583, 0.59382379055023, 0.68377721309662, 0.56132888793945, 0.64781379699707, 0.3820595741272, 0.39514243602753, 0.43889796733856, 0.24185287952423, 0.39842092990875, 0.57490038871765, 0.29444801807404, 0.59192395210266, 0.49333620071411, 0.47158122062683, 0.70923662185669, 0.56123471260071, 0.74068117141724, 0.61222243309021, 0.5908899307251, 0.49585425853729, 0.53937041759491, 0.50305330753326, 0.59863924980164, 0.54027462005615, 0.55338287353516, 0.64472568035126, 0.41938185691833, 0.47443020343781, 0.44711911678314, 0.63114726543427, 0.43179655075073, 0.49202489852905, 0.46892118453979, 0.44588780403137, 0.43955659866333, 0.33980751037598, 0.36311709880829, 0.37560904026031, 0.42090237140656, 0.39685010910034, 0.36213254928589, 0.36959230899811, 0.40261602401733, 0.45956933498383, 0.585981965065, 0.55830669403076, 0.68996620178223, 0.53538930416107, 0.37111449241638 ];
);
)

/*
~shesme.notes.start;
~shesme.notes.fade = 1;
~shesme.notes.fade = 0;
~shesme.notes.end;
*/