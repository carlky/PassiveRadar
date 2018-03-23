% DO NOT RUN UNLESS ON LINUX TEST SYSTEM!!!

nsamples = 4e6;
nreceivers = 3;
f_sample = 1e6;
filename = strings(1,nreceivers);
f_rec = 900e6;
f_sync = 900e6;
space = " ";
cmdin = strcat(".", filesep,  "mutlirtl_3chanRX_to_cfile.py", space, ...
    "--samp-rate", space, num2str(f_sample), space, ...
    "--nsamples", space, num2str(nsamples), space, ...
    "--f-rec", space, num2str(f_rec), space, ...
    "--f-sync", space, num2str(f_sync), space);
for i=1:nreceivers
    filename(i) = [pwd filesep 'ch' num2str(i-1) '.cfile'];
    cmdin = strcat(cmdin,space,"--ch",num2str(i-1),"-fname",space,filename(i));
end

%%
clc;
[status,cmdout] = system(cmdin);

if status == 0
    disp('Everything went well!');
else
    disp('ERRORS!');
    disp(cmdout);
end
%%
v = zeros(nreceivers,nsamples);
for i = 1:nreceivers
    v(i,:) = read_complex_binary(filename(i),nsamples);
    saveData(f_rec,f_sample,v(i,:));
    pause(1);
end


