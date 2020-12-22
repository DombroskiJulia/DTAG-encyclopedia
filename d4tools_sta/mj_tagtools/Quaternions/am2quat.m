function [q,incl] = am2quat(A,M)
%
%   q = am2quat(A,M)
%   Compute quaternion corresponding to rotation from earth frame to tag or
%   whale frame. Replace prh.
%   Inputs:
%   A is the nx3 acceleration matrix
%   M is the nx3 magnetometer signal matrix in uT (microtesla) 
%
%   Anne Piemont
%   Created 22 Aug 2013
%   Last modified 12 Sept 2013
%
q = zeros(size(A,1),4);
for k=1:size(A,1)
    vA = sqrt(A(k,:)*A(k,:)'); % if there is no specific acceleration, vA=g
    vM = sqrt(M(k,:)*M(k,:)'); % vM = b (magnetic field intensity)
    % Inclination of magnetic intensity
    x = A(k,:)*M(k,:)'/(vA*vM);
    incl = asin(x);
%     x=sin(incl);
    
    a = A(k,1)/(-2*vA);
%    b = A(k,2)/(2*vA); % unused
    c = A(k,3)/vA;
    d = (M(k,1)/vM + 2*a*x)/sqrt(1-x^2);
    if abs(d)<1e-10 % round up to 0
        d=0;
    end;
%    e = (M(k,2)/vM - 2*b*sin(incl))/(2*cos(incl)); %unused
    f = (M(k,3)/vM - c*x)/(2*sqrt(1-x^2));
    if abs(f)<1e-10 % round up to 0
        f=0;
    end;
    
    %   Solving the equations gives 4 potential solutions (2 parameters  
    %   taking each 2 different values). Each will be stored in a row of 
    %   the array s and tested afterwards.
    s=zeros(4);

    %% Compute q1&q3 and store solutions in s
    if a-f==0
        if c-d>0
            s(:,1) = 0;
            s(1:2,3) = sqrt((c-d)/2);
            s(3:4,3) = -sqrt((c-d)/2);
        elseif c-d==0
            s(:,1) = 0;
            s(:,3) = 0;
        else
            s(1:2,1) = sqrt((d-c)/2);
            s(3:4,1) = -sqrt((d-c)/2);
            s(:,3) = 0;
        end;
    else
        delta = ((c-d)/2)^2+(a-f)^2;
        s(1:2,1) = sqrt((-(c-d)/2+sqrt(delta))/2);
        s(3:4,1) = -sqrt((-(c-d)/2+sqrt(delta))/2);
        s(:,3) = (a-f)*[1;1;1;1]./(2*s(:,1));
    end;
    
    %% Compute q2&q4 and store solutions in s
    if a+f==0
        if c+d>0
            s(:,4) = 0;
            s([1,3],2) = sqrt((c+d)/2);
            s([2,4],2) = -sqrt((c+d)/2);
        elseif c+d==0
            s(:,2) = 0;
            s(:,4) = 0;
        else
            s([1,3],4) = sqrt(-(c+d)/2);
            s([2,4],4) = -sqrt(-(c+d)/2);
            s(:,2) = 0;
        end;
    else
        delta = ((c+d)/2)^2+(a+f)^2;
        s([1,3],4) = sqrt((-(c+d)/2+sqrt(delta))/2);
        s([2,4],4) = -sqrt((-(c+d)/2+sqrt(delta))/2);
        s(:,2) = (a+f)*[1;1;1;1]./(2*s(:,4));
    end;
    
    %% Test results stored in s
    j = 1;
    ok = false;
    G = [0,0,0,-vA];
    B = [0,vM*sqrt(1-x^2),0,-vM*x];
    while j<=4 && ok==false
        p=1/(s(j,:).^2*[1;1;1;1])*[s(j,1),-s(j,2:4)]; %p is the inverse of s(j,:)
        Atest = quatprod(quatprod(s(j,:),G),p);
        Mtest = quatprod(quatprod(s(j,:),B),p);
        if all((Atest(2:4)-A(k,:))/norm(A(k,:))<1e-6) && all((Mtest(2:4)-M(k,:))/norm(M(k,:))<1e-6)
           ok=true;
        else
            j=j+1;
        end;
    end;
    q(k,:)=s(j,:);

end;