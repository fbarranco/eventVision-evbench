
%pathfile = '/home/fran/prueba';
pathfile = '/home/fran/WORK/calibration_data/my_output/worked_final';

files = dir(fullfile(pathfile, 'd-*.pgm'));

tmp = imread(fullfile(pathfile,files(1).name));
data = swapbytes(tmp);
[~, distance_old] = depthToCloud(data);

for k=2:length(files)
   tmp = imread(fullfile(pathfile,files(k).name));
   data = swapbytes(tmp);
   [~, distance_new] = depthToCloud(data);
   
   distance = 0.5*(distance_new + distance_old);
   nan_mask = isnan(distance);
   
   tmp_new = distance_new(nan_mask);
   tmp_old = distance_old(nan_mask);
   tmp_new(isnan(tmp_new))=0; 
   tmp_old(isnan(tmp_old))=0;
   tmp_sum = tmp_new+tmp_old; % The non NaN values, would be the values for the final result
   tmp_sum(tmp_sum==0)=NaN;
   distance(nan_mask)=tmp_sum;
      
   distance_old = distance;
end

distance=mediannan(distance,5);
distance=mediannan(distance,5);

keyboard