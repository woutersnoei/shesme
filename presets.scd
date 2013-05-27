EM( 'ikzoekjeniet', OEM(  ), 'broken', OEM(  ), 'laughing', OEM(  ), 'notes', OEM(  ), 
  'words', OEM(  ), 'chords', OEM(  ), 'sfr', OEM( 'sss', EM( 'transpose', 1.6849865951743, 'convolve', 0.0, 'rvar', 0.0, 'speed', 11.370971921683, 
  'tvar', 1.5, 'range', [ 0.1, 0.9 ], 'mode', 's', 'overlap', 8.0, 'useWinbuf', false, 
  'filter', 0.35497654155496 ), 'rrr', EM( 'transpose', 0.0, 'convolve', 0.0, 'rvar', 0.0, 'speed', 11.370971921683, 
  'tvar', 1.5, 'range', [ 0.1, 0.9 ], 'mode', 'r', 'overlap', 8.0, 'useWinbuf', false, 
  'filter', -0.024631367292225 ), 'clicks', EM( 'transpose', 0.25335120643431, 'convolve', 1.0, 'rvar', 1.4155495978552, 'speed', 2.3604199475518, 
  'tvar', 0.25092158176944, 'range', [ 0.1, 0.9 ], 'mode', 'r', 'overlap', 0.125, 'useWinbuf', true, 
  'filter', -0.024631367292225 ), 'sjj', EM( 'rvar', 0.0, 'convolve', 0.28162701072386, 'filter', -0.034601206434316, 'speed', 11.370971921683, 
  'tvar', 1.5, 'range', [ 0.1, 0.9 ], 'mode', 's', 'overlap', 8.0, 'useWinbuf', false, 
  'transpose', -7.1943699731903 ), 
  'tttt', EM( 'rvar', 1.4155495978552, 'convolve', 0.0, 'filter', -0.024631367292225, 'speed', 3.2089820826941, 
  'tvar', 1.2050100536193, 'range', [ 0.1, 0.9 ], 'mode', 's', 'overlap', 0.125, 'useWinbuf', true, 
  'transpose', 0.25335120643431 ), 'rollig', EM( 'transpose', -18.227211796247, 'useWinbuf', true, 'rvar', 1.9901139410188, 'speed', 43.752413083025, 
  'tvar', 1.1758545576408, 'range', [ 0.1, 0.9 ], 'mode', 's', 'overlap', 0.5, 'convolve', 0.81677278820375, 
  'filter', -0.328418230563 ), 'granular', EM( 'transpose', 0.62398785425101, 'speed', 12.03378721599, 'tvar', 1.1758545576408, 'range', [ 0.1, 0.9 ], 
  'pan', [ -2, 2 ], 'mode', 'r', 'useWinbuf', true, 'filter', 0.89271255060729, 'convolve', 0.0, 
  'duck', 0.0, 'overlap', 0.375, 'rvar', 1.6499240890688 ), 'slow ffs', EM( 'transpose', -4.1735829959514, 'speed', 1.0, 'tvar', 0.25092158176944, 'range', [ 0.1, 0.9 ], 
  'pan', [ -2, 2 ], 'mode', 'f', 'useWinbuf', false, 'filter', -0.024631367292225, 'convolve', 0.0, 
  'duck', 0.47150797619505, 'overlap', 0.125, 'rvar', 12.0 ) ), 'pattern', OEM(  ), 'tttt', OEM(  ), 
  'mumbling', OEM( 'rhythm', EM( 'speed', 4.0, 'duck', 0.0, 'pan', [ -1.0, 1.0 ], 'spvar', false, 
  'verb', 0.0, 'useWinbuf', true, 'filter', -0.013474190283401 ), 'dress', EM( 'speed', 200.0, 'duck', 0.0, 'pan', [ -1.0, 1.0 ], 'spvar', true, 
  'verb', 0.24329453441296, 'useWinbuf', false, 'filter', 0.96046305668016 ), 'low', EM( 'speed', 0.61893496475435, 'duck', 0.0, 'pan', [ -1.0, 1.0 ], 'spvar', true, 
  'verb', 0.063670293522267, 'useWinbuf', false, 'filter', -0.87265941295547 ), 'normal', EM( 'speed', 2.7580799439589, 'duck', 0.0, 'pan', [ -1.0, 1.0 ], 'spvar', true, 
  'verb', 0.0, 'useWinbuf', false, 'filter', 0.0084767206477734 ) ), 'humming', OEM(  ), 'rrrr', OEM(  ), 'wapentuig', OEM(  ), 'coupler', OEM( 'dress', EM( 'current', EM( 'd2', [ [ 'sfr', 'duck', [ 0.15, 0.25, 0, 1 ], nil ], [ 'mumbling', 'duck', [ 0.1, 0.3, 1, 0 ], nil ], [ 'mumbling', 'filter', [ 0.3, 0.8, 0.97, 0.2 ], nil ] ] ) ), 'off', EM( 'current', EM(  ) ), 'climbing', EM( 'current', EM( 'd2', [ [ 'mumbling', 'speed', [ 0.025, 0.1, 0, 0.4 ], nil ] ], 'press2', [ [ 'tttt', 'speed', [ 0.75, 0.9 ], nil ] ] ) ), 'rhythm', EM( 'current', EM( 'z2', [ [ 'broken', 'amp', { |which, key, val|
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
  'pattern', EM( 'current', EM( 'd2', [ [ 'pattern', 'scream', [ 0.05, 0.075, 1, 0 ], nil ] ] ) ) ) )