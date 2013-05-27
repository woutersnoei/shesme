(
// note:
// turn on web sharing in web sharing panel first

~shesme = ~shesme ? EM();

~shesme.dataNetwork = ~shesme.dataNetwork ? EM();

~shesme.dataNetwork.useMiniBee = true;

~shesme.dataNetwork.vals = ~shesme.dataNetwork.vals ? OEM();

~shesme.dataNetwork.vals.which = 0;

/*
~shesme.dataNetwork.vals.which = 1;
*/

~shesme.dataNetwork.vals.ddecay = 0.25;

~shesme.dataNetwork.startPython = { 
	"cd '%/ssdn_python-master/pydon'; python metapydonhive.py"
			.format( ~shesme.path.dirname ).runInTerminal;
};

~shesme.dataNetwork.startNetwork = { |evt|
	evt.n = SWDataNetwork.new.createHost;
	evt.n.makeGui;
};

~shesme.dataNetwork.bend1range = [0.45,0.65];
~shesme.dataNetwork.bend2range = [0.55,0.75];
~shesme.dataNetwork.press1range = [0.4,0.9];
~shesme.dataNetwork.press2range = [0.5,1];

~shesme.dataNetwork.startRegistering = { |evt|
	if( evt.n.notNil ) {
		evt.n.addHook( 1, {
			evt.n.nodes[1].slots[0].action = { |data|
				if( evt.vals[ \which ] == 0 ) {
					evt.vals[ \bend1 ] = data.linlin(evt.bend1range[0], evt.bend1range[1], 0,1,\none);
					evt.vals[ \bend2 ] = data.linlin(evt.bend1range[0], evt.bend1range[1], 0,1,\none);
				};
			};
			evt.n.nodes[1].slots[1].action = { |data|
				if( evt.vals[ \which ] == 0 ) {
					evt.vals[ \press1 ] = (1-data).linlin(evt.press1range[0], evt.press1range[1], 0,1,\none);
					evt.vals[ \press2 ] = (1-data).linlin(evt.press1range[0], evt.press1range[1], 0,1,\none);
				};
			};
			evt.n.nodes[1].slots[4].action = { |data|
				if( evt.vals[ \which ] == 0 ) {
					evt.vals[ \x1 ]  = data.linlin(0.46,0.54,0,1,\none);
					evt.vals[ \x2 ]  = data.linlin(0.46,0.54,0,1,\none);
				};
			};
			evt.n.nodes[1].slots[5].action = { |data|
				if( evt.vals[ \which ] == 0 ) {
					evt.vals[ \y1 ] = data.linlin(0.46,0.54,0,1,\none);
					evt.vals[ \y2 ] = data.linlin(0.46,0.54,0,1,\none);
				};
			};
			evt.n.nodes[1].slots[6].action = { |data|
				if( evt.vals[ \which ] == 0 ) {
					evt.vals[ \z1 ]  = data.linlin(0.46,0.54,0,1,\none);
					evt.vals[ \z2 ]  = data.linlin(0.46,0.54,0,1,\none);
				};
			};
		});
		evt.n.addHook( 2, {
			evt.n.nodes[2].slots[0].action = { |data|
				if( evt.vals[ \which ] == 1 ) {
					evt.vals[ \bend1 ] = data.linlin(evt.bend2range[0], evt.bend2range[1], 0,1,\none);
					evt.vals[ \bend2 ] = data.linlin(evt.bend2range[0], evt.bend2range[1], 0,1,\none);
				};
			};
			evt.n.nodes[2].slots[1].action = { |data|
				if( evt.vals[ \which ] == 1 ) {
					evt.vals[ \press1 ] = (1-data).linlin(evt.press2range[0], evt.press2range[1], 0,1,\none);
					evt.vals[ \press2 ] = (1-data).linlin(evt.press2range[0], evt.press2range[1], 0,1,\none);
				};
			};

			evt.n.nodes[2].slots[4].action = { |data|
				if( evt.vals[ \which ] == 1 ) {
					evt.vals[ \x1 ]  = data.linlin(0.46,0.54,0,1,\none);
					evt.vals[ \x2 ]  = data.linlin(0.46,0.54,0,1,\none);
				};
			};
			evt.n.nodes[2].slots[5].action = { |data|
				if( evt.vals[ \which ] == 1 ) {
					evt.vals[ \y1 ] = data.linlin(0.46,0.54,0,1,\none);
					evt.vals[ \y2 ] = data.linlin(0.46,0.54,0,1,\none);
				};
			};
			evt.n.nodes[2].slots[6].action = { |data|
				if( evt.vals[ \which ] == 1 ) {
					evt.vals[ \z1 ]  = data.linlin(0.46,0.54,0,1,\none);
					evt.vals[ \z2 ]  = data.linlin(0.46,0.54,0,1,\none);
				};
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
				dvals = dvals.abs;
				evt.vals[ \d1 ] = dvals[..2].mean
					.blend( evt.vals[ \d1 ] ? 0, evt.vals.ddecay ? 0.25 );
				evt.vals[ \d2 ] = dvals[3..].mean
					.blend( evt.vals[ \d2 ] ? 0, evt.vals.ddecay ? 0.25 );
				oldvals = vals;
			};
		}).start;
	} {
		"can't register vals because network is not active".postln;
	};
};

~shesme.dataNetwork.makeWindow = { |evt|
	var ctrl;
	evt.window = Window("shesme sensors", Rect(
		Window.screenBounds.width - 250, 605, 250, 300) 
	).front;
	evt.window.addFlowLayout;
	evt.window.onClose_({ ctrl.remove });
	evt.views = ();
	ctrl = SimpleController( evt.vals );
	[1,2].collect({ |i|
		[ "bend", "press", "x", "y", "z", "d" ].collect({ |item| (item ++ i).asSymbol });
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
	evt.ddecaySlider = EZSmoothSlider( evt.window, (evt.window.bounds.width - 8) @ 16, "ddecay", 
			[0,1].asSpec, { |sl| evt.vals.ddecay = sl.value }, evt.vals.ddecay ? 0.25);
	evt.ddecaySlider.view.resize_(2);
	ctrl.put( \ddecay, {
		evt.ddecaySlider.value = evt.vals.ddecay;
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

/*
~shesme.dataNetwork.startPython;
~shesme.dataNetwork.startNetwork;
~shesme.dataNetwork.startRegistering;
~shesme.dataNetwork.makeWindow;
~shesme.dataNetwork.vals.ddecay = 0.25;
*/
)