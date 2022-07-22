%     Supporting material software to the article 
%     "Statistical modeling of adaptive neural networks 
%     explains coexistence of avalanches and oscillations in resting human brain "
%     Copyright (C) 2022 F. Lombardi et al.
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
Data_set = 'test_MEG';

Sensor_Dir = dir(strcat(Data_set,'*'));

Num_file = length(Sensor_Dir);         % Number of subjects

%% Set experimental parameters

Num_ele = 273;                %number of sensors

Fs = 600;                     %sampling frequency

nsamples = 144000;            %number of samples = Fs x (Duration of recording in sec)

%% Set bin size and threhold for extreme events and avalanche analysis

    bin = 2;                               % Bin size (in number of samples; 1 = 1.67 ms)
    
    num_bin = floor(nsamples/bin);         % Number of time bins
    
    thresh = 2.9;                          % Threshold for avalanche detection
    
%% Find avalanches and extreme events

    for i = 1 : Num_file
           
           meg_active_nele_bin = cell(1,1);
           
           meg_signal_ths = zeros(nsamples,1);                 % signals crossing threshold
           
           meg_signal_ths_bin = zeros(num_bin,Num_ele);        % #extremes in each time bin for each sensor 
           meg_nele_ths_bin = zeros(num_bin,1);                % #active sensor in each time bin 
           meg_tot_ths_bin = zeros(num_bin,1);                 % #sum of extremes in each time bin
                                 
           subj_num = num2str(i);
           
           % Load MEG file "meg_signal" (144000 x 273)
           
           Path_Load = strcat(Sensor_Dir(i).name);
           meg_signal = load(Path_Load)';
           
           for j = 1 : Num_ele
               
           % normalize signal    
               mean_sig = mean(meg_signal.y_pre(j,:));
  
               std_sig = std(meg_signal.y_pre(j,:));
                 
               meg_signal_z = (meg_signal.y_pre(j,:) - mean_sig)/std_sig;
                
           % get positive and negative extremes over threshold for sensor j
           
               meg_signal_ths_p = (meg_signal_z >=  thresh).*meg_signal_z;
               meg_signal_ths_m = (meg_signal_z <= -thresh).*meg_signal_z;
               
               meg_signal_ths_p = tip_over_ths(meg_signal_ths_p,thresh);      % positive
               meg_signal_ths_m = tip_over_ths(meg_signal_ths_m,thresh);      % negative
           
           % combine positive and negative
           
               for ii = 1 : nsamples
                   meg_signal_ths(ii) = meg_signal_ths_p(ii) + meg_signal_ths_m(ii);
               end
                         
            % Binning
               
               k=1;
               step = bin;
               
               for j1 = 1 : step : nsamples-bin+1
                   
                   meg_signal_ths_bin(k,j) = sum(abs(meg_signal_ths(j1:(j1+bin-1))));
                   
                   if meg_signal_ths_bin(k,j) ~= 0
                      meg_tot_ths_bin(k,1) = meg_tot_ths_bin(k,1) + meg_signal_ths_bin(k,j);
                      meg_nele_ths_bin(k,1) = meg_nele_ths_bin(k,1) + 1;
                   end
                   
                   k = k+1;    
                end
           
            end
                      
           % Calculate avalanches
           
           num_aval = 0;                  % Number of avalanches
           ava_size_nele = [];            % Avalanche size in number of active sensors                     
           ava_dur = [];                  % Avalanche duration 
           start_ava = [];                % Avalanche starting time
           end_ava = [];                  % Avalanche ending time
           
           
           ind_zeros = find(meg_nele_ths_bin == 0);
           
           size_ioz = size(ind_zeros,1);
           
           k=1;
           
           for i1 = 1:(size_ioz-1)
               
               diff_ind_zeros = ind_zeros(i1+1)-ind_zeros(i1);
               
               if diff_ind_zeros > 1
                   num_aval = num_aval + 1;
                   num_bin_ava = diff_ind_zeros - 1;
                   start_ava(k)=ind_zeros(i1) + 1;
                   end_ava(k)=ind_zeros(i1+1)-1;
                   ava_dur(k) = num_bin_ava*bin;
                   ava_size_nele(k) = sum(meg_nele_ths_bin(ind_zeros(i1):ind_zeros(i1+1)));
                   ava_size_vol(k) = sum(meg_tot_ths_bin(ind_zeros(i1):ind_zeros(i1+1)));
                   k=k+1;
               end
               
           end
          
          % Plot avalanche size distribution
          
          [P_size_nele,edge_size_nele] = histcounts(ava_size_nele,'Normalization','probability',...
               'BinMethod','integers','BinLimits',[0,1000]);
           figure(1)
           edge_start_bin = edge_size_nele(1:end-1);
           ind_dt_gt_0 = find(P_size_nele > 0);
           loglog(edge_start_bin(ind_dt_gt_0),P_size_nele(ind_dt_gt_0));
           hold on
           
           % Save avalanches
           
           bavat = [start_ava' end_ava' ava_size_nele' ava_size_vol'];
           
           out_file = strcat('test_avalanche_subject_',subj_num,'.dat');

           save(out_file,'bavat','-ascii')
           
           
%%         Extreme events

           bin_series = meg_nele_ths_bin;
    
           num_bin = length(bin_series);

           ind_lt0_element = find(bin_series < 0);
    
           bin_series(ind_lt0_element) = 0;
           
           ind_no_zeros = find(bin_series > 0);
           
           bin_act_rate = bin_series(ind_no_zeros);
           
           num_empty_bin = diff(ind_no_zeros) - 1;
           
           num_empty_bin = num_empty_bin(num_empty_bin > 0);
           
           % Distribution of activity per bin P(A)
           
           [P_bin_rate,edge_bin_rate] = histcounts(bin_act_rate,'Normalization','probability',...
               'BinMethod','integers','BinLimits',[0,Num_ele]);
           
           figure(2)
           edge_start_bin_act = edge_bin_rate(1:end-1);
           ind_rate_gt_0 = find(P_bin_rate > 0);
           semilogy(edge_start_bin_act(ind_rate_gt_0),P_bin_rate(ind_rate_gt_0));
           hold on
           
           % Distribution of quiescent periods P(I)
           
           [P_empty_bin,edge_empty_bin] = histcounts(num_empty_bin,'Normalization','probability',...
               'BinMethod','integers','BinLimits',[0,num_bin]);
           
           figure(3)
           edge_start_bin_empty = edge_empty_bin(1:end-1);
           ind_rate_gt_0 = find(P_empty_bin > 0);
           loglog(edge_start_bin_empty(ind_rate_gt_0),P_empty_bin(ind_rate_gt_0));
           hold on
                   
           % Save file with #extremes per bin ("meg_nele_ths_bin")
           
           out_file = strcat('test_extreme_events_subject_',subj_num,'.dat');

           save(out_file,'meg_nele_ths_bin','-ascii','-double') 
    end
       