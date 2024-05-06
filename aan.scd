//verison 0.0.1
(
Task(
	{
		Server.default = Server.local;
		o = Server.default.options;
		o.memSize_(2.pow(20));
		ServerOptions.devices;
		o.inDevice_("Scarlett 4i4 USB");
		o.outDevice_("External Headphones");
		s.reboot;
		s.latency_(0.5);
		2.wait;
		~timer = LinkClock.new(2).latency_(Server.default.latency).quantum_(0);
		b = Buffer.alloc(s, s.sampleRate * (~timer.beatDur*512), 1);
		2.wait;
		~micBus = Bus.audio(s, 1);
		~ptrBus = Bus.audio(s, 1);
		2.wait;
		Window.closeAll;
		w = Window("scope",Rect(0,Window.availableBounds.height/2,1024,768))
		.background_(Color.black)
		.alpha_(0.75)
		.visible_(true)
		.front
		.onClose_({~topScope.stop; ~bf.free; ~fb.free});
		~color_vals = Array.fill(3,{Array.fill(3,{rrand(0,255)})});
		~bf = Buffer.alloc(s,4096,2);
		~fb = Bus.audio(s,2);
		~topScope = ScopeView(w,
			Rect(0,
				0,
				w.view.bounds.width,
				w.view.bounds.height))
		.bufnum_(~bf.bufnum)
		.server_(Server.default)
		.style_(2)
		.xZoom_(10)
		.yZoom_(10)
		.waveColors_(
			[
				Color.new255(
					~color_vals[0][0],
					~color_vals[1][0],
					~color_vals[2][0]
				),
				Color.new255(
					~color_vals[0][1],
					~color_vals[1][1],
					~color_vals[2][1]
				)
			]
		)
		.background_(Color.black)
		.start;
		~colorChanger = Task({
			var delta = ~timer.beatDur/64;
			loop {
				3.do({
					arg i;
					3.do({
						arg j;
						if(
							~color_vals[i][j] == 255,
							{
								~color_vals[i][j] = ~color_vals[i][j]-[0,1].choose
							}
						);
						if(
							~color_vals[i][j] == 0,
							{
								~color_vals[i][j] = ~color_vals[i][j]+[0,1].choose
							}
						);
						if(
							(~color_vals[i][j] < 255) && (~color_vals[i][j] > 0),
							{
								~color_vals[i][j] = ~color_vals[i][j]+[0,1,-1].wchoose([0.5,0.25,0.25])
							}
						);
					});
				});
				~topScope.waveColors_(
					[
						Color.new255(
							~color_vals[0][0],
							~color_vals[1][0],
							~color_vals[2][0]
						),
						Color.new255(
							~color_vals[0][1],
							~color_vals[1][1],
							~color_vals[2][1]
						)
					]
				);
				delta.yield;
			}
		},AppClock
		).play;
		x = Window(
			"buttons",
			Rect(
				Window.availableBounds.width*0.75,
				Window.availableBounds.height/10,
				Window.availableBounds.width-w.bounds.width,
				96
			)
		)
		.background_(Color.black)
		.alpha_(0.75)
		.visible_(true)
		.front;
		~mic_onoff = Button(x,x.bounds.width/5@x.bounds.height)
		.states_(
			[
				[
					" ",
					Color.new(1,1,1,0.25),
					Color.new(1,1,1,0.25)
				],
				[
					" ",
					Color.new(1,1,1,0.75),
					Color.new(1,1,1,0.75)
				]
			]
		).mouseDownAction_(
			{
				arg view;
				if(
					view.value == 3,
					{
						view.value = 1
					}
				);
				if(
					view.value == 0,
					{
						k.set(\amp,0.5);
						l.set(\amp,0.5);
						m.set(\amp,0.5);
						n.set(\amp,0.5);
						"microphone on".postln
					},
					{
						k.set(\amp,0);
						l.set(\amp,0);
						m.set(\amp,0);
						n.set(\amp,0);
						"microphone off".postln
					}
				)
			}
		).value_(1);
		~mic_shifter = Button(x,Rect(~mic_onoff.bounds.width,0,x.bounds.width/5,x.bounds.height))
		.states_(
			[
				[
					" ",
					Color.new(1,1,1,0.25),
					Color.new(1,1,1,0.25)
				],
				[
					" ",
					Color.new(1,1,1,0.75),
					Color.new(1,1,1,0.75)
				]
			]
		).mouseDownAction_(
			{
				arg view;
				if(
					view.value == 3,
					{
						view.value = 1
					}
				);
				if(
					view.value == 0,
					{
						j.set(\shift,0.75);
						k.set(\shift,0.75);
						l.set(\shift,0.75);
						m.set(\shift,0.75);
						n.set(\shift,0.75);
						"pitch shifter activated".postln
					},
					{
						j.set(\shift,1);
						k.set(\shift,1);
						l.set(\shift,1);
						m.set(\shift,1);
						n.set(\shift,1);
						"pitch shifter deactivated".postln
					}
				)
			}
		).value_(0);
		~delmic_onoff = Button(x,Rect(~mic_onoff.bounds.width+~mic_shifter.bounds.width,0,x.bounds.width/5,x.bounds.height))
		.states_(
			[
				[
					" ",
					Color.new(1,1,1,0.25),
					Color.new(1,1,1,0.25)
				],
				[
					" ",
					Color.new(1,1,1,0.75),
					Color.new(1,1,1,0.75)
				]
			]
		).mouseDownAction_(
			{
				arg view;
				if(
					view.value == 3,
					{
						view.value = 1
					}
				);
				if(
					view.value == 0,
					{
						j.set(\amp,0.5);
						"delay input on".postln
					},
					{
						j.set(\amp,0);
						"delay input off".postln
					}
				)
			}
		).value_(0);
		~delout_onoff = Button(x,Rect(~mic_onoff.bounds.width+~mic_shifter.bounds.width+~delmic_onoff.bounds.width,0,x.bounds.width/5,x.bounds.height))
		.states_(
			[
				[
					" ",
					Color.new(1,1,1,0.25),
					Color.new(1,1,1,0.25)
				],
				[
					" ",
					Color.new(1,1,1,0.75),
					Color.new(1,1,1,0.75)
				]
			]
		).mouseDownAction_(
			{
				arg view;
				if(
					view.value == 3,
					{
						view.value = 1
					}
				);
				if(
					view.value == 0,
					{
						16.do(
							{
								arg i;
								~g[i].set(\amp,~ampLFOs[i])
							}
						);
						"delay output on".postln
					},
					{
						16.do(
							{
								arg i;
								~g[i].set(\amp,0)
							}
						);
						"delay output off".postln
					}
				)
			}
		).value_(1);
		~colorChanger_onoff = Button(x,Rect(~mic_onoff.bounds.width+~mic_shifter.bounds.width+~delmic_onoff.bounds.width+~delout_onoff.bounds.width,0,x.bounds.width/5,x.bounds.height))
		.states_(
			[
				[
					" ",
					Color.new(1,1,1,0.25),
					Color.new(1,1,1,0.25)
				],
				[
					" ",
					Color.new(1,1,1,0.75),
					Color.new(1,1,1,0.75)
				]
			]
		).mouseDownAction_(
			{
				arg view;
				if(
					view.value == 3,
					{
						view.value = 1
					}
				);
				if(
					view.value == 0,
					{
						~colorChanger.play;
						"scope set to color changing mode".postln
					},
					{
						~colorChanger.stop;
						~topScope.waveColors_([Color.white,Color.grey]);
						"scope set to black & white mode".postln
					}
				)
			}
		).value_(1);
		SynthDef.new(\shiftMic, {
			arg in = 0, out = 0, shift = 1, amp = 1;
			var sig;
			sig = PitchShift.ar(
				SoundIn.ar(in),
				0.2,
				shift,
				0.0,
				0.004
			)* amp;
			Out.ar(out, sig);
		}).add;
		SynthDef(\ptr, {
			arg out = 0, buf = 0, rate = 1;
			var sig;
			sig = Phasor.ar(0, BufRateScale.kr(buf)*rate, 0, BufFrames.kr(buf));
			Out.ar(out, sig);
		}).add;
		SynthDef.new(\rec, {
			arg ptrIn = 0, micIn = 0, buf = 0;
			var ptr, sig;
			ptr = In.ar(ptrIn, 1);
			sig = In.ar(micIn, 1);
			BufWr.ar(sig, buf, ptr);
		}).add;
		SynthDef(\gran, {
			arg amp = 0.5, buf = 0, out = 0,
			atk = 1, rel = 1, gate = 1,
			sync = 1, dens = 40,
			baseDur = 0.05, durRand = 1,
			rate = 1, rateRand = 1,
			pan = 0, panRand = 0,
			grainEnv = (-1), ptrBus = 0, ptrSampleDelay = 20000,
			ptrRandSamples = 5000, minPtrDelay = 1000;
			var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl,
			ptr, ptrRand, totalDelay, maxGrainDur;
			env = EnvGen.kr(Env.asr(atk,1,rel), gate, doneAction: 2);
			densCtrl = Select.ar(sync, [Dust.ar(dens), Impulse.ar(dens)]);
			durCtrl = baseDur * LFNoise1.ar(100).exprange(1/durRand, durRand);
			rateCtrl = rate.lag3(0.5) * LFNoise1.ar(100).exprange(1/rateRand, rateRand);
			panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);
			ptrRand = LFNoise1.ar(100).bipolar(ptrRandSamples);
			totalDelay = max(ptrSampleDelay - ptrRand, minPtrDelay);
			ptr = In.ar(ptrBus, 1);
			ptr = ptr - totalDelay;
			ptr = ptr / BufFrames.kr(buf);
			maxGrainDur = (totalDelay / rateCtrl) / SampleRate.ir;
			durCtrl = min(durCtrl, maxGrainDur);
			sig = GrainBuf.ar(
				2,
				densCtrl,
				durCtrl,
				buf,
				rateCtrl,
				ptr,
				4,
				panCtrl,
				grainEnv
			);
			sig = MoogFF.ar(
				sig * env * amp,
				freq: \cutoff.kr(12000),
				gain: \resonance.kr(1)
			);
			Out.ar(out, sig);
		}).add;
		2.wait;
		~micGrp = Group.new;
		~ptrGrp = Group.after(~micGrp);
		~recGrp = Group.after(~ptrGrp);
		~granGrp = Group.after(~recGroup);
		2.wait;
		j = Synth(\shiftMic, [\in, 0, \out, ~micBus, \amp, 0], ~micGrp);
		k = Synth(\shiftMic, [\in, 0, \out, 0, \amp, 0.5], ~granGrp);
		l = Synth(\shiftMic, [\in, 0, \out, 1, \amp, 0.5], ~granGrp);
		m = Synth(\shiftMic, [\in, 0, \out, ~fb.index, \amp, 0.5], ~micGrp);
		n = Synth(\shiftMic, [\in, 0, \out, ~fb.index+1, \amp, 0.5], ~granGrp);
		o = Synth(\ptr, [\buf, b, \out, ~ptrBus], ~ptrGrp);
		p = Synth(\rec, [\ptrIn, ~ptrBus, \micIn, ~micBus, \buf, b], ~recGrp);
		~panLFOs = Array.fill(16, {0});
		~ampLFOs = Array.fill(16, {0});
		~cutoffLFOs = Array.fill(16, {0});
		~resonanceLFOs = Array.fill(16, {0});
		2.wait;
		16.do({
			arg i;
			~panLFOs.put(i,
				Ndef(i.asSymbol, {
					LFTri.kr(~timer.beatDur/rrand(1,64)).range(-1,1)
				})
			);
			~ampLFOs.put(i,
				Ndef(i+16.asSymbol, {
					LFTri.kr(~timer.beatDur/rrand(1,64)).range(1,3)
				})
			);
			~cutoffLFOs.put(i,
				Ndef((i+32).asSymbol, {
					LFTri.kr(~timer.beatDur/rrand(1,64)).range(500,12000)
				})
			);
			~resonanceLFOs.put(i,
				Ndef((i+48).asSymbol, {
					LFTri.kr(~timer.beatDur/rrand(1,64)).range(0,2)
				})
			)
		});
		~af = SynthDef("duoscope", { arg bus, bufnum;
			var z;
			z = In.ar(bus, 2);
			ScopeOut2.ar(z, bufnum);
			Out.ar(0, z);
		}).play(
			target: RootNode(Server.default),
			args: [\bus, ~fb.index, \bufnum, ~bf.bufnum],
			addAction: \addToTail
		);
		~timer.beatDur*4.wait;
		~rates = [1/4,2/6,3/8,4/10,1/2,2/3,3/4,4/5,1,5/4,4/3,3/2,2/1,10/4,8/3,6/2].scramble;
		~durs = 16.collect({arg i; ~timer.beatDur*(i+1)}).scramble;
		~delays = 16.collect({arg i; s.sampleRate*(~timer.beatDur*(i+1))*16}).scramble;
		~g = 16.collect({
			arg n;
			Synth(\gran, [
				\amp, ~ampLFOs[n],
				\buf, b,
				\out, ~fb.index,
				\atk, 1,
				\rel, 1,
				\gate, 1,
				\sync, 1,
				\dens, 1/(~durs[n]*~rates[n]),
				\baseDur, ~durs[n],
				\durRand, 1,
				\rate, ~rates[n],
				\rateRand, 1,
				\pan, ~panLFOs[n],
				\panRand, 0,
				\grainEnv, -1,
				\ptrBus, ~ptrBus,
				\ptrSampleDelay, ~delays[n],
				\ptrRandSamples, s.sampleRate*(~timer.beatDur*((n%8)+1))*2,
				\minPtrDelay, ~delays[n],
				\cutoff, ~cutoffLFOs[n],
				\resonance, ~resonanceLFOs[n]
			], ~granGrp;
			)
		});
}).play(AppClock)
)