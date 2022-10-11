function [data] = get_ksp(acq, acq_header, recon_header)
%GET_KSP Summary of this function goes here
%   Detailed explanation goes here

% Unpack necessary parameters
discard = recon_header.pre_discard;
Nd      = recon_header.Nd;
Npe     = recon_header.Npe;
Nslc    = recon_header.Nslc;
Nkz     = recon_header.Nkz;
Nc      = recon_header.Nc;
Neco    = recon_header.Neco;

acq = acq.select(find(~acq.head.flagIsSet(acq.head.FLAGS.ACQ_IS_NOISE_MEASUREMENT)));
acq_header = acq.head;
% Sort data 
data = complex(zeros(Nd, Npe, Nkz, Nc, 1, Neco, 1, 1,1,1,1,1,1, Nslc, 'single'));
for eco_i = 1:Neco
    for slc_i = 1:Nslc
        profile_list = find(acq_header.idx.set == (eco_i-1) ...
                          & acq_header.idx.slice    == (slc_i-1));
        for idx1 = 1:length(profile_list)
            %------------------------------------------------------------------
            % Determine the interleaf number
            %------------------------------------------------------------------
            pe1_index = acq_header.idx.kspace_encode_step_1(profile_list(idx1)) + 1;
            pe2_index = acq_header.idx.kspace_encode_step_2(profile_list(idx1)) + 1;
            profile = acq.data{profile_list(idx1)}; % number_of_samples x nr_channels
            data(:, pe1_index, pe2_index, :, 1, eco_i,:,:,:,:,:,:,:,slc_i)...
                = reshape(profile(discard:end,:), [Nd 1 1 Nc]);
        end
    end
end

end

