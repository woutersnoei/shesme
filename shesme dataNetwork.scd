(
// note:
// turn on web sharing in web sharing panel first

~shesme = ~shesme ? EM();

~shesme.dataNetwork = ~shesme.dataNetwork ? EM();

~shesme.dataNetwork.useMiniBee = true;

~shesme.dataNetwork.vals = ~shesme.dataNetwork.vals ? OEM();

~shesme.dataNetwork.startPython = { 
	"cd '%/ssdn_python-master/pydon'; python metapydonhive.py"
			.format( ~shesme.path.dirname ).runInTerminal;
};

~shesme.dataNetwork.startNetwork = { |evt|
	evt.n = SWDataNetwork.new.createHost;
	evt.n.makeGui;
};

~shesme.dataNetwork.bend1range = [0.45,0.58];
~shesme.dataNetwork.bend2range = [0.45,0.63];
~shesme.dataNetwork.press1range = [0,0.5];
~shesme.dataNetwork.press2range = [0,0.5];

~shesme.dataNetwork.startRegistering = { |evt|
	if( evt.n.notNil ) {
		evt.n.addHook( 1, {
			evt.n.nodes[1].slots[0].action = { |data|
				evt.vals[ \bend1 ] = data.linlin(evt.bend1range[0], evt.bend1range[1], 0,1);
			};
			evt.n.nodes[1].slots[1].action = { |data|
				evt.vals[ \press1 ] = (1-data).linlin(evt.press1range[0], evt.press1range[1], 0,1);
			};
			evt.n.nodes[1].slots[4].action = { |data|
				evt.vals[ \x1 ]  = data.linlin(0.46,0.54,0,1);
			};
			evt.n.nodes[1].slots[5].action = { |data|
				evt.vals[ \y1 ] = data.linlin(0.46,0.54,0,1);
			};
			evt.n.nodes[1].slots[6].action = { |data|
				evt.vals[ \z1 ]  = data.linlin(0.46,0.54,0,1);
			};
		});
		evt.n.addHook( 2, {
			evt.n.nodes[1].slots[0].action = { |data|
				evt.vals[ \bend2 ] = data.linlin(evt.bend2range[0], evt.bend2range[1], 0,1);
			};
			evt.n.nodes[1].slots[1].action = { |data|
				evt.vals[ \press2 ] = (1-data).linlin(evt.press2range[0], evt.press2range[1], 0,1);
			};
			evt.n.nodes[1].slots[4].action = { |data|
				evt.vals[ \x2 ]  = data.linlin(0.46,0.54,0,1);
			};
			evt.n.nodes[1].slots[5].action = { |data|
				evt.vals[ \y2 ] = data.linlin(0.46,0.54,0,1);
			};
			evt.n.nodes[1].slots[6].action = { |data|
				evt.vals[ \z2 ]  = data.linlin(0.46,0.54,0,1);
			};
		});
		evt.dtask.stop;
		evt.dtask = Task({
			var oldvals, vals, dvals;
			oldvals = #[ x1, y1, z1, x2, y2, z2 ].collect({ |item|
				evt.vals[ item ] ? 0.5;
			});
			loop {
				0.1.wait;
				vals =  #[ x1, y1, z1, x2, y2, z2 ].collect({ |item|
					evt.vals[ item ] ? 0.5;
				});
				dvals = oldvals - vals;
				evt.vals[ \d1 ] = dvals[..2].mean + 0.5; 
				evt.vals[ \d2 ] = dvals[3..].mean + 0.5; 
				oldvals = vals;
			};
		}).start;
	} {
		"can't register vals because network is not active".postln;
	};
};

~shesme.dataNetwork.makeWindow = { |evt|
	var ctrl;
	evt.window = Window("shesme sensors", Rect(1045, 605, 300, 244) ).front;
	evt.window.addFlowLayout;
	evt.window.onClose_({ ctrl.remove });
	evt.views = ();
	ctrl = SimpleController( evt.vals );
	[1,2].collect({ |i|
		[ "press", "bend", "x", "y", "z", "d" ].collect({ |item| (item ++ i).asSymbol });
	}).flatten(1).do({ |item|
		var view;
		view = EZSmoothSlider( evt.window, (evt.window.bounds.width - 8) @ 16, item, 
			[0,1].asSpec, { |sl| evt.vals[ item ] = sl.value });
		view.view.resize_(2);
		ctrl.put( item, {
			view.value = evt.vals[ item ];
		});
		evt.views[ item ] = view;
	});
};

~shesme.dataNetwork.start = { |evt|
	if( evt.useMiniBee == true ) {
		evt.startPython;
		evt.startNetwork;
		evt.startRegistering;
	};
	evt.makeWindow;
};

~shesme = ~shesme ? EM();

~shesme.coupler = ~shesme.coupler ? EM();

~shesme.coupler.current = EM();

~shesme.coupler.settings = EM();

~shesme.coupler.performCurrent = { |evt, sensor = 'x1', val = 0|
	evt.current[ sensor ].do({ |array|
		var which, key, func;
		#which, key, func = array;
		case { func.isNil } {
			 ~shesme[ which ].mapSet( key, val );
		} { func.isKindOf( Spec ) } {
			~shesme[ which ].mapSet( key, func.unmap( val ) );
		} { func.isKindOf( Collection ) } {
			~shesme[ which ].mapSet( key, 
				val.linlin( func[0] ? 0, func[1] ? 1, func[2] ? 0, func[3] ? 1, \minmax ) 
			);
		} {
			func.value( ~shesme[ which ], key, val );
		};
	});
};

~shesme.coupler[ \updateFunc ] = ~shesme.coupler[ \updateFunc ]  ?? { { |obj, key, val|
	~shesme.coupler.performCurrent( key, val );
} };

~shesme.dataNetwork.vals.addDependant( ~shesme.coupler[ \updateFunc ] );

/*
~shesme.dataNetwork.vals.removeDependant( ~shesme.coupler[ \updateFunc ] );
~shesme.coupler[ \updateFunc ] = nil;
*/

~shesme.coupler.couple = { |evt, sensor = 'x1', which = 'tttt', key = 'speed', func|
	evt.current[ sensor ] = evt.current[ sensor ].add( [ which, key, func ] );
};

~shesme.coupler.uncouple = { |evt, sensor = 'x1', which = 'tttt', key = 'speed'|
	var removeThese;
	removeThese = evt.current[ sensor ] !? _.select({ |item| 
		(item[0] == which) && (item[1] == key)
	});
	removeThese.do({ |item| evt.current[ sensor ].remove( item ) });
	if( evt.current[ sensor ].size == 0 ) { evt.current[ sensor ] = nil };
};

/*
~shesme.dataNetwork.startPython;
~shesme.dataNetwork.startNetwork;
~shesme.dataNetwork.startRegistering;
*/
)