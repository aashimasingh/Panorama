function [pano] = imagemultiply(xmin , ymin, pano, I, H)
    [row,col,~] = size(I);
    for r = 1:row
        for c = 1:col
            w = H * [c ; r ; 1];
            w = w./w(3);
            w = round(w(1:2) - [xmin; ymin]);
            xdash = w(2);
            ydash = w(1);
            if (ydash > 0 & xdash > 0)
            pano(xdash,ydash,:) = I(r,c,:);
            end
        end
    end

end

