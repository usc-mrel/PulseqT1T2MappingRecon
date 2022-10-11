function asFlipAngleTextCb(obj,alpha)
    selstr = obj.selection.getValue();
    fa_i = str2double(selstr(end));
    imtxt = sprintf('FA=%.2f', alpha(fa_i));
%     disp(imtxt)

    if obj.isInitialized()
        obj.createImageText(imtxt);
    end
end

