function [ptsfinal,soln] = do_ransac(matchedPoints1, matchedPoints2)
iter = 50;
C= 0;
maxi = 0;
lmax = size(matchedPoints1,1);
for i = 1:iter
        homography = zeros(8,9);
    
        ind = randi(lmax,4,1);
        match1 = matchedPoints1(ind,:);
        match2 = matchedPoints2(ind,:);
        for j = 1:4
            xa = match1(j,1);
            ya = match1(j,2);
            xb = match2(j,1);
            yb = match2(j,2);
            homography(2*j-1,:) = [xa,ya,1,0,0,0,-xb*xa,-xb*ya, -xb];
            homography(2*j,:) = [0,0,0,xa,ya,1,-yb*xa,-yb*ya,-yb];
        end
        [u,s,v] = svd(homography);
    
        sol = v(:,end);
        sol = reshape(sol,[3,3])';
    
        coord = sol * [matchedPoints1 ones(lmax,1)]';
        normcoord = [coord(1,:)./coord(3,:); coord(2,:)./coord(3,:);ones(1,lmax)];
    
        dist = normcoord - [matchedPoints2 ones(lmax,1)]';
    
        mag = sqrt(sum(dist.^2,1));
        RansacLogic = mag < 30;
        C = size(find(RansacLogic),2);
        disp(C);
        if maxi < C
            maxi = C;
            ptsfinal1 = matchedPoints1(find(RansacLogic),:);
            ptsfinal2 = matchedPoints2(find(RansacLogic),:);
        end
end
homofinal = zeros(2*C,9);
for k = 1:C
    x1 = ptsfinal1(k,1);
    y1 = ptsfinal1(k,2);
    x1bar = ptsfinal2(k,1);
    y1bar = ptsfinal2(k,2);
    homofinal(2*k-1,:) = [x1,y1,1,0,0,0,-x1bar*x1,-x1bar*y1, -x1bar];
    homofinal(2*k,:) = [0,0,0,x1,y1,1,-y1bar*x1,-y1bar*y1,-y1bar];
end
[u1,s1,v1] = svd(homofinal);
soln = v1(:,end);
soln = - reshape(soln,[3,3])';
%soln = soln./soln(3,3);
ptsfinal = [ptsfinal1 ptsfinal2];
end