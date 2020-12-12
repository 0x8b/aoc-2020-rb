k,n,s,e,w,r,l=0,1i,-1i,1,-1,-1i,1i;a,d,b,x,u=k,e,k,10+n,->y{a+=y;x+=y}
DATA.map{|q|t,v=q[0],q[1..].to_i;z=v/90
case t;in ?N;u[v*n];in ?S;u[v*s];in ?W;u[v*w];in ?E;u[v*e]
in ?F;a+=v*d;b+=v*x;in ?L;d*=l**z;x*=l**z;in ?R;d*=r**z;x*=r**z;end}
[a,b].map{|w|p w.rect.sum &:abs}