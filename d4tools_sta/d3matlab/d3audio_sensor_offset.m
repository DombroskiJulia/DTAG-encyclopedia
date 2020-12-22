function    t = d3audio_sensor_offset(recdir,prefix)
%
%     t = d3audio_sensor_offset(recdir,prefix)
%     Returns the time difference between the start time of the audio
%     and the sensor recording in a DTAG deployment. The unit is seconds.
%     This function works for DTAG-2 and DTAG-3.
%     A positive number means that the sensor recording
%     started t seconds after the audio recording.
%     To align audio and sensor data, add t seconds to
%     the sensor time axis.
%     recdir is the deployment directory e.g., 'e:/eg15/eg15_207a'.
%     prefix is the base part of the name of the files to analyse e.g., 
%        if the files have names like 'eg207a001.wav', put prefix='eg207a'.
%
%     Example:
%        t=d3audio_sensor_offset('e:/data/bb10','bb215a') ;
%
%     Updated 12/2/16 improved help
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013


t = NaN ;
if isempty(recdir),
   try      % see if this is a DTAG2
      t = audio_sensor_offset(prefix) ;
   catch
      fprintf('Unknown DTAG-2 tag recording\n') ;
   end
else
   try
      [cw,rw] = d3getcues(recdir,prefix) ;
      [cs,rs] = d3getcues(recdir,prefix,'swv') ;
      t = (rs-rw)+(cs(1,2)-cw(1,2)) ;
   catch
      fprintf('Unknown DTAG-3 tag recording\n') ;
   end
end
