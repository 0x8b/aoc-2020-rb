a,d,e,n=0,1i,1,-1;k,w,b,x,u,l,v,t=a,e,a,10+d,->y{k+=y;x+=y},d,-d,-d
DATA.map{|q|r,s=q[0],q[1..].to_i;z,m=s/90,->d{w*=d**z;x*=d**z}
case r;in ?N;u[s*d];in ?S;u[s*v];in ?W;u[s*n];in ?E;u[s*e]
in ?F;k+=s*w;b+=s*x;else;m[r==?L?l:t];end}
[k,b].map{|n|p n.rect.sum &:abs}