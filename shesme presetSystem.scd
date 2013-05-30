(
~shesme = ~shesme ? EM();

~shesme.presetSystem = ~shesme.presetSystem ? EM();

~shesme.presetSystem.presets = EM();

~shesme.names.do({ |name|
	if( ~shesme[ name ].specs.notNil && { 
		~shesme[ name ].specs.keys.select(_ != \amp).size > 0 
	} ) {
		~shesme.presetSystem.presets[ name ] = OEM();
		~shesme[ name ].getPreset = { |evt, key|
			var preset, keys;
			preset = EM();
			evt.specs.keys.do({ |key|
				if( key != \amp ) {
					preset[ key ] = evt[ key ].deepCopy;
				};
			});
			~shesme.presetSystem.presets[ name ][ key ] = preset;
		};
		~shesme[ name ].applyPreset = { |evt, dict|
			var preset, keys;
			if( dict.isKindOf( Symbol ) ) {
				dict = ~shesme.presetSystem.presets[ name ][ dict ];
			};
			if( dict.notNil ) {
				dict.keysValuesDo({ |key, value|
					evt.perform( key.asSetter, value.deepCopy );
				});
			};
		};
		~shesme[ name ].presetNames = { ~shesme.presetSystem.presets[ name ].keys };
		~shesme[ name ].presetNames_ = { |evt, newNames|
			var oldPresets;
			oldPresets = ~shesme.presetSystem.presets[ name ];
			~shesme.presetSystem.presets[ name ] = OEM();
			newNames.do({ |key|
				key = key.asSymbol;
				~shesme.presetSystem.presets[ name ][ key ] = oldPresets[ key ];
			});
		};
		~shesme[ name ].presetValues = { ~shesme.presetSystem.presets[ name ].values };
	};
});

~shesme.presetSystem.save = { |evt|
	File.use( ~shesme.path +/+ "presets.scd", "w", { |f|
		f.putString(  ~shesme.presetSystem.presets.cs )
	});
};

~shesme.presetSystem.read = { |evt|
	if( File.exists(~shesme.path +/+ "presets.scd") ) {
		evt.presets = (~shesme.path +/+ "presets.scd").load;
	};
};

~shesme.presetSystem.readAdd = { |evt|
	if( File.exists(~shesme.path +/+ "presets.scd") ) {
		evt.presets = evt.presets ++ (~shesme.path +/+ "presets.scd").load;
	};
};

~shesme.presetSystem.readAdd;

/*
~shesme.presetSystem.save;
~shesme.presetSystem.read;
~shesme.presetSystem.readAdd; // use if a new name was added to presets
*/
)