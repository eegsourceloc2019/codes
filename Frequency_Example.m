%% Example of localizing sinusoidal signal at 40 Hz as per distributed dipole condition

load('Forward_Var_Colin.mat');
load('data_base_freq');
% Simulation
scale=[72.4 89.5 103.5 116 127.2];

for ii=1:5  
    fun=[];
    fun.grid=grid;
    fun.headmodel=vol;
    fun.elec=elec;
    fun.model='dist';
    fun.signal='sin';
    fun.noise_perc_sensor =0;
    fun.noise_perc_l=0;
    fun.noise_perc_r=0;
    fun.dip_pos=[-60, -28 ,-6; 64, -24 ,6];
    fun.scale=scale(ii);
    fun.phase=0;
    [data_sim]=fun_simulation(fun);
    
    Stim_Base{ii}=data_sim;
    Stim_Base{ii}.trial{1}=data_sim.trial{1}+Baseline';
    
    Base=data_sim;
    Base.trial{1}=Baseline';
end

%% Plot the signal embedded in baseline

figure;plot(Stim_Base{1}.trial{1}');
%% Source Localization

for ii=1:5
    fun=[];
    fun.grid=grid;
    fun.headmodel=vol;
    fun.elec=elec;
    fun.analysis='frequency';
    fun.simdata=Stim_Base{ii};
    fun.basedata=Base;
    fun.freq=[40 40];
    fun.taper=2;
    fun.mri=mri;
    fun.pow='contrast';
    
    [source_eLOR_sim{ii}, source_LCMV_sim, source_MNE_sim, source_DICS_sim{ii}] = fun_SL(fun);
    
    z_thr=0.9999;
    [Z_DICS{ii},Z_DICS_P{ii}] = source_zscore(source_DICS_sim,'dist',z_thr);
    [Z_eLOR{ii},Z_eLOR_P{ii}] = source_zscore(source_eLOR_sim,'dist',z_thr);
    
    % plotting on surface
    dip_pos=[-60, -28 ,-6; 64, -24 ,6];
    figure;
    coords2surf2(Z_eLOR{ii}{1},Z_DICS{ii}{1},dip_pos,[]); %(red, green, blue, pink)
end