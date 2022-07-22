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
%
function[dev]=tip_over_ths(tseries,thresh)
%
%     Find most extreme values in exursions beyond threshold
%     dev=tip_over_ths(tseries,thresh) 
%     tseries : the signal after the threhold has been applied ("meg_signal_ths" from meg_analysis.m )
%     thresh  : the threhshold value
%     dev: sequence of extremes 
%
dev1 = 0;
devmax = 0;
imax = 0;
dev=tseries;
for i = 1:length(dev)
    if abs(dev(i)) <= thresh
       dev(i) = 0;
       dev1 = dev(i);
    else
       if dev1 == 0
          devmax = abs(dev(i));
          imax = i;
          dev1 = abs(dev(i));
       else
          if devmax < abs(dev(i))
              devmax = abs(dev(i));
              dev1 = abs(dev(i));
              dev(imax) = 0;
              imax =i;
          else
              dev1 = abs(dev(i));
              dev(i) = 0;
          end
       end
    
    end
end
