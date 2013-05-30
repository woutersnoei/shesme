EM( 'coupler', OEM( 'dress', EM( 'current', EM( 'd2', [ [ 'sfr', 'duck', [ 0.15, 0.25, 0, 1 ], nil ], [ 'mumbling', 'filter', [ 0.7, 1, 0.97, 0.75 ], nil ], [ 'mumbling', 'duck', [ 0.3, 0.5, 1, 0 ], nil ], [ 'humming', 'duck', [ 0.3, 0.5, 0, 1 ], nil ], [ 'humming', 'amp', { |which, key, val|
	if( val > 0.3 ) {
		if( ~shesme.humming.active.not ) {~shesme.humming.start; };
		~shesme.wapentuig.end;
	};
}, nil ] ] ) ), 'off', EM( 'current', EM(  ) ), 'climbing', EM( 'current', EM( 'd2', [ [ 'mumbling', 'speed', [ 0.0125, 0.1, 0, 0.7 ], nil ], [ 'tttt', 'speed', [ 0.075, 0.1, 0.2, 1 ], nil ] ] ) ), 'rhythm', EM( 'current', EM( 'z2', [ [ 'broken', 'amp', { |which, key, val|
			if( which.active == true ) {
				if( val < 0.4 ) {
					which.end;
				};
			} {
				if( val > 0.6 && { ~shesme.dataNetwork.vals[ \d2 ] < 0.05 } ) {
					which.start;
				};
			};
		}, nil ], [ 'mumbling', 'amp', { |which, key, val|
			if( which.active == true ) {
				if( val > 0.6 && { ~shesme.dataNetwork.vals[ \d2 ] < 0.05 } ) {
					which.end;
				};
			} {
				if( val < 0.4 ) {
					which.start;
				};
			};
		}, nil ] ] ) ), 
  'pattern', EM( 'current', EM( 'd2', [ [ 'pattern', 'scream', [ 0.05, 0.075, 1, 0 ], nil ] ] ) ) ), 'broken', OEM(  ), 'laughing', OEM( 'default', EM( 'pan', [ -2, 2 ], 'pbrate', 0.97352195825295, 'verb', 0.0, 'brassage', 0.0, 
  'pos', 0.5, 'filter', -0.029921558704453 ), 'dark', EM( 'pan', [ -2, 2 ], 'pbrate', 0.31701243475391, 'verb', 1.0, 'brassage', 0.0, 
  'pos', 0.5, 'filter', -0.43528593117409 ), 'birdlike', EM( 'pan', [ -2, 2 ], 'pbrate', 4.0, 'verb', 1.0, 'brassage', 0.61509994939271, 
  'pos', 0.5, 'filter', 0.72931427125506 ) ), 'notes', OEM(  ), 
  'quotes', OEM(  ), 'words', OEM( 'all', EM( 'trigger', 1, 'index', [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ], 'which', 'all' ), 'love', EM( 'trigger', 1, 'index', [ 0, 9 ], 'which', 'all' ) ), 'chords', OEM(  ), 'pattern', OEM(  ), 'sfr', OEM( 'sss', EM( 'rvar', 0.0, 'convolve', 0.0, 'filter', 0.35497654155496, 'speed', 11.370971921683, 
  'tvar', 1.5, 'range', [ 0.1, 0.9 ], 'mode', 's', 'overlap', 8.0, 'useWinbuf', false, 
  'transpose', 1.6849865951743 ), 'rrr', EM( 'rvar', 0.0, 'convolve', 0.0, 'filter', -0.024631367292225, 'speed', 11.370971921683, 
  'tvar', 1.5, 'range', [ 0.1, 0.9 ], 'mode', 'r', 'overlap', 8.0, 'useWinbuf', false, 
  'transpose', 0.0 ), 'clicks', EM( 'rvar', 1.4155495978552, 'convolve', 1.0, 'filter', -0.024631367292225, 'speed', 2.3604199475518, 
  'tvar', 0.25092158176944, 'range', [ 0.1, 0.9 ], 'mode', 'r', 'overlap', 0.125, 'useWinbuf', true, 
  'transpose', 0.25335120643431 ), 'sjj', EM( 'filter', -0.034601206434316, 'convolve', 0.28162701072386, 'transpose', -7.1943699731903, 'speed', 11.370971921683, 
  'tvar', 1.5, 'range', [ 0.1, 0.9 ], 'mode', 's', 'overlap', 8.0, 'useWinbuf', false, 
  'rvar', 0.0 ), 
  'tttt', EM( 'filter', -0.024631367292225, 'convolve', 0.0, 'transpose', 0.25335120643431, 'speed', 3.2089820826941, 
  'tvar', 1.2050100536193, 'range', [ 0.1, 0.9 ], 'mode', 's', 'overlap', 0.125, 'useWinbuf', true, 
  'rvar', 1.4155495978552 ), 'rollig', EM( 'rvar', 1.9901139410188, 'useWinbuf', true, 'filter', -0.328418230563, 'speed', 43.752413083025, 
  'tvar', 1.1758545576408, 'range', [ 0.1, 0.9 ], 'mode', 's', 'overlap', 0.5, 'convolve', 0.81677278820375, 
  'transpose', -18.227211796247 ), 'granular', EM( 'transpose', 0.62398785425101, 'speed', 12.03378721599, 'tvar', 1.1758545576408, 'range', [ 0.1, 0.9 ], 
  'pan', [ -2, 2 ], 'mode', 'r', 'useWinbuf', true, 'filter', 0.89271255060729, 'convolve', 0.0, 
  'duck', 0.0, 'overlap', 0.375, 'rvar', 1.6499240890688 ), 'slow ffs', EM( 'transpose', -4.1735829959514, 'speed', 1.0, 'tvar', 0.25092158176944, 'range', [ 0.1, 0.9 ], 
  'pan', [ -2, 2 ], 'mode', 'f', 'useWinbuf', false, 'filter', -0.024631367292225, 'convolve', 0.0, 
  'duck', 0.47150797619505, 'overlap', 0.125, 'rvar', 12.0 ), 'dripping', EM( 'transpose', 0.25335120643431, 'speed', 1.4981111223534, 'tvar', 0.27726467611336, 'range', [ 0.1, 0.9 ], 
  'pan', [ -2, 2 ], 'mode', 'f', 'useWinbuf', true, 'filter', 0.011196862348178, 'convolve', 1.0, 
  'duck', 0.47150797619505, 'overlap', 0.125, 'rvar', 1.4155495978552 ), 
  'rrr-end', EM( 'rvar', 0.0, 'speed', 11.370971921683, 'tvar', 1.5, 'range', [ 0.1, 0.9 ], 
  'pan', [ 0.4, 0.6 ], 'mode', 'r', 'convolve', 0.0, 'filter', 0.5511766194332, 'useWinbuf', false, 
  'duck', 0.0, 'overlap', 8.0, 'transpose', -0.056174089068829 ) ), 
  'tttt', OEM(  ), 'mumbling', OEM( 'rhythm', EM( 'speed', 4.0, 'duck', 0.0, 'pan', [ -1.0, 1.0 ], 'spvar', false, 
  'verb', 0.0, 'useWinbuf', true, 'filter', -0.013474190283401 ), 'dress', EM( 'speed', 200.0, 'duck', 0.0, 'pan', [ -1.0, 1.0 ], 'spvar', true, 
  'verb', 0.24329453441296, 'useWinbuf', false, 'filter', 0.96046305668016 ), 'low', EM( 'speed', 0.61893496475435, 'duck', 0.0, 'pan', [ -1.0, 1.0 ], 'spvar', true, 
  'verb', 0.063670293522267, 'useWinbuf', false, 'filter', -0.87265941295547 ), 'normal', EM( 'speed', 2.7580799439589, 'duck', 0.0, 'pan', [ -1.0, 1.0 ], 'spvar', true, 
  'verb', 0.0, 'useWinbuf', false, 'filter', 0.0084767206477734 ), 
  'fragments', EM( 'speed', 1.1826172793177, 'duck', 0.0, 'pan', [ -1.0, 1.0 ], 'spvar', true, 
  'verb', 0.063670293522267, 'useWinbuf', false, 'filter', 0.47551872469636 ) ), 'humming', OEM(  ), 'rrrr', OEM(  ), 'wapentuig', OEM(  ), 
  'ikzoekjeniet', OEM(  ) )