
(()=>{'use strict';

const c=document.getElementById('c');
const x=c.getContext('2d');
const scoreE=document.getElementById('score');
const lenE=document.getElementById('len');
const timeE=document.getElementById('time');
const center=document.getElementById('center');
const pauseMark=document.getElementById('pauseMark');

let dpr=1,last=performance.now();

const verticalDirs={
  KeyJ:[0,1,0,'+Y'],
  KeyK:[0,-1,0,'−Y']
};

let cfg={
  speed:2,
  motion:'smooth',
  size:9,
  zoom:2
};

const S={
  started:false,
  paused:false,
  over:false,
  t:0,
  score:0,
  moves:0,
  body:[],
  prev:[],
  dir:[0,0,1,'+Z'],
  queued:null,
  orb:null,
  clock:0,
  yaw:.78,
  pitch:.58,
  firstMove:true
};

const ORB_MARGIN=1;
const eq=(a,b)=>a[0]===b[0]&&a[1]===b[1]&&a[2]===b[2];
const opp=(a,b)=>a[0]===-b[0]&&a[1]===-b[1]&&a[2]===-b[2];
const rnd=n=>Math.floor(Math.random()*n);
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));

function resize(){
  dpr=Math.min(devicePixelRatio||1,1.6);
  c.width=innerWidth*dpr;
  c.height=innerHeight*dpr;
}
addEventListener('resize',resize);
resize();

function dragonCell(p){
  return p[0]>=0&&p[0]<cfg.size&&
         p[1]>=0&&p[1]<cfg.size&&
         p[2]>=0&&p[2]<cfg.size;
}

function orbCell(p){
  const hi=cfg.size-1-ORB_MARGIN;
  return p[0]>=ORB_MARGIN&&p[0]<=hi&&
         p[1]>=ORB_MARGIN&&p[1]<=hi&&
         p[2]>=ORB_MARGIN&&p[2]<=hi;
}

function orb(){
  const lo=ORB_MARGIN;
  const hi=cfg.size-1-ORB_MARGIN;
  const span=hi-lo+1;
  for(let k=0;k<1000;k++){
    const p=[lo+rnd(span),lo+rnd(span),lo+rnd(span)];
    if(orbCell(p)&&!S.body.some(q=>eq(p,q))){
      S.orb=p;
      return;
    }
  }
}

function reset(){
  const m=Math.floor(cfg.size/2);
  S.started=false;
  S.paused=false;
  S.over=false;
  S.t=0;
  S.score=0;
  S.moves=0;
  S.clock=0;
  S.dir=[0,0,1,'+Z'];
  S.queued=null;
  S.firstMove=true;
  S.body=[[m,m,m],[m,m,m-1]];
  S.prev=S.body.map(p=>p.slice());
  orb();
  center.classList.remove('hide');
  center.querySelector('h1').textContent='VOXEL ANACONDA';
  center.querySelector('p').textContent='Usa los controles táctiles para empezar. El cubo azul es todo tu espacio; el cubo naranja solo limita dónde aparecen los orbes.';
  hud();
}

function vsub(a,b){return[a[0]-b[0],a[1]-b[1],a[2]-b[2]]}
function dot(a,b){return a[0]*b[0]+a[1]*b[1]+a[2]*b[2]}
function cross(a,b){return[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]}
function norm(a){const l=Math.hypot(...a)||1;return a.map(v=>v/l)}

function camera(){
  const n=cfg.size;
  const target=[(n-1)/2,(n-1)/2,(n-1)/2];
  const yaw=S.yaw;
  const p=S.pitch;
  const effectiveZoom=1+(cfg.zoom-1)*0.55;
  const dist=(n*2.2+5)/effectiveZoom;
  const pos=[
    target[0]+Math.cos(p)*Math.sin(yaw)*dist,
    target[1]+Math.sin(p)*dist,
    target[2]+Math.cos(p)*Math.cos(yaw)*dist
  ];
  const f=norm(vsub(target,pos));
  const r=norm(cross(f,[0,1,0]));
  const u=norm(cross(r,f));
  return{pos,f,r,u,F:Math.min(c.width,c.height)*.82};
}

function horizontalAxesFromCamera(){
  const C=camera();

  let rx=C.r[0],rz=C.r[2];
  let right;
  if(Math.abs(rx)>=Math.abs(rz)) right=[Math.sign(rx)||1,0,0,''];
  else right=[0,0,Math.sign(rz)||1,''];

  let fx=C.u[0],fz=C.u[2];
  let forward;
  if(Math.abs(fx)>=Math.abs(fz)) forward=[Math.sign(fx)||1,0,0,''];
  else forward=[0,0,Math.sign(fz)||1,''];

  if((right[0]!==0&&forward[0]!==0)||(right[2]!==0&&forward[2]!==0)){
    if(right[0]!==0) forward=[0,0,-right[0],''];
    else forward=[right[2],0,0,''];
  }

  const label=v=>{
    if(v[0]===1)return'+X';
    if(v[0]===-1)return'−X';
    if(v[2]===1)return'+Z';
    if(v[2]===-1)return'−Z';
    return'';
  };

  right[3]=label(right);
  forward[3]=label(forward);

  const left=[-right[0],0,-right[2],label([-right[0],0,-right[2]])];
  const back=[-forward[0],0,-forward[2],label([-forward[0],0,-forward[2]])];

  return{KeyW:forward,KeyS:back,KeyA:left,KeyD:right};
}

function dirForKey(code){
  if(verticalDirs[code])return verticalDirs[code];
  return horizontalAxesFromCamera()[code]||null;
}

function queue(v){
  if(S.over)return;

  if(!S.started){
    // El primer toque DEFINE la dirección inicial.
    // No heredamos el +Z técnico usado al crear el estado.
    S.started=true;
    S.firstMove=false;
    S.dir=v.slice();
    S.queued=null;

    // Recolocar la única pieza de cola detrás de la cabeza.
    // Así cualquier primera dirección es válida y nunca empieza
    // intentando girar 180° contra una cola creada para otro eje.
    const h=S.body[0];
    S.body=[
      h.slice(),
      [h[0]-v[0],h[1]-v[1],h[2]-v[2]]
    ];
    S.prev=S.body.map(p=>p.slice());

    center.classList.add('hide');
    return;
  }

  if(!opp(v,S.dir))S.queued=v;
}

function die(msg,details={}){
  S.over=true;
  S.paused=false;
  center.classList.add('hide');

  try{
    if(window.FlutterGame && window.FlutterGame.postMessage){
      window.FlutterGame.postMessage(JSON.stringify({
        type:'gameOver',
        message:msg,
        score:S.score,
        length:S.body.length,
        moves:S.moves,
        head:S.body[0],
        ...details
      }));
    }
  }catch(_){}
}

function step(){
  S.prev=S.body.map(p=>p.slice());

  if(S.queued&&!opp(S.queued,S.dir))S.dir=S.queued;
  S.queued=null;

  const h=S.body[0];
  const n=[h[0]+S.dir[0],h[1]+S.dir[1],h[2]+S.dir[2]];

  if(!dragonCell(n)){
    die('Golpeaste una pared del cubo grande.',{attempted:n});
    return;
  }

  const eat=eq(n,S.orb);
  const chk=eat?S.body:S.body.slice(0,-1);

  if(chk.some(p=>eq(p,n))){
    die('Chocaste con tu propio cuerpo.',{attempted:n});
    return;
  }

  S.body.unshift(n);
  S.moves++;

  if(eat){
    S.score+=100+S.body.length*5;
    orb();
  }else{
    S.body.pop();
  }

  S.score++;
  hud();
}

function update(dt){
  if(!S.started||S.paused||S.over)return;

  S.t+=dt;
  S.clock+=dt*cfg.speed;

  while(S.clock>=1&&!S.over){
    S.clock--;
    step();
  }

  hud();
}

function hud(){
  scoreE.textContent=S.score;
  lenE.textContent=S.body.length;
  const s=Math.floor(S.t);
  timeE.textContent=Math.floor(s/60)+':'+String(s%60).padStart(2,'0');
}

function proj(p,C){
  const q=vsub(p,C.pos);
  const z=dot(q,C.f);
  if(z<=.2)return null;
  const s=C.F/z;
  return[
    c.width/2+dot(q,C.r)*s,
    c.height/2-dot(q,C.u)*s,
    z,s
  ];
}

function line(a,b,C,col,w=1){
  const A=proj(a,C),B=proj(b,C);
  if(!A||!B)return;
  x.strokeStyle=col;
  x.lineWidth=w*dpr;
  x.beginPath();
  x.moveTo(A[0],A[1]);
  x.lineTo(B[0],B[1]);
  x.stroke();
}

function grid(C){
  const N=cfg.size;
  const lo=-.5,hi=N-.5;
  const vs=[
    [lo,lo,lo],[hi,lo,lo],[hi,hi,lo],[lo,hi,lo],
    [lo,lo,hi],[hi,lo,hi],[hi,hi,hi],[lo,hi,hi]
  ];
  const ed=[
    [0,1],[1,2],[2,3],[3,0],
    [4,5],[5,6],[6,7],[7,4],
    [0,4],[1,5],[2,6],[3,7]
  ];

  ed.forEach(e=>line(vs[e[0]],vs[e[1]],C,'#9fb8ff88',1.7));

  // Rejilla de centros de celdas. Las paredes quedan media celda por fuera,
  // de modo que una celda legal nunca se dibuje atravesando la pared.
  for(let i=0;i<N;i++){
    const col='rgba(120,150,235,.13)';
    line([i,lo,lo],[i,lo,hi],C,col);
    line([lo,lo,i],[hi,lo,i],C,col);
    line([i,lo,hi],[i,hi,hi],C,col);
    line([lo,i,hi],[hi,i,hi],C,col);
    line([lo,i,lo],[lo,i,hi],C,col);
    line([lo,lo,i],[lo,hi,i],C,col);
  }
}

function orbZone(C){
  const lo=ORB_MARGIN-.5;
  const hi=(cfg.size-1-ORB_MARGIN)+.5;
  const vs=[
    [lo,lo,lo],[hi,lo,lo],[hi,hi,lo],[lo,hi,lo],
    [lo,lo,hi],[hi,lo,hi],[hi,hi,hi],[lo,hi,hi]
  ];
  const ed=[
    [0,1],[1,2],[2,3],[3,0],
    [4,5],[5,6],[6,7],[7,4],
    [0,4],[1,5],[2,6],[3,7]
  ];
  ed.forEach(e=>line(vs[e[0]],vs[e[1]],C,'rgba(255,184,86,.34)',1.35));
}

function shadow(head,C){
  const ground=[head[0],0,head[2]];
  const q=proj(ground,C);
  if(!q)return;

  const R=Math.max(5*dpr,q[3]*.18);

  x.save();
  x.globalAlpha=.25;
  x.fillStyle='#000';
  x.beginPath();
  x.ellipse(q[0],q[1],R*1.45,R*.78,0,0,Math.PI*2);
  x.fill();
  x.restore();
}

function interp(i){
  if(cfg.motion==='snap'||!S.started)return S.body[i];

  const t=Math.min(1,S.clock);
  const e=t*t*(3-2*t);
  const a=S.prev[i]||S.body[i];
  const b=S.body[i];

  return[
    a[0]+(b[0]-a[0])*e,
    a[1]+(b[1]-a[1])*e,
    a[2]+(b[2]-a[2])*e
  ];
}

function cube(p,C,s,fill,stroke){
  const h=s/2;

  const vs=[
    [-h,-h,-h],[h,-h,-h],[h,h,-h],[-h,h,-h],
    [-h,-h,h],[h,-h,h],[h,h,h],[-h,h,h]
  ].map(v=>[p[0]+v[0],p[1]+v[1],p[2]+v[2]]);

  const ps=vs.map(v=>proj(v,C));
  const fs=[
    [0,1,2,3],[4,5,6,7],[0,1,5,4],
    [2,3,7,6],[1,2,6,5],[0,3,7,4]
  ];
  const ds=[];

  fs.forEach(f=>{
    if(f.every(i=>ps[i])){
      ds.push([f,f.reduce((q,i)=>q+ps[i][2],0)/4]);
    }
  });

  ds.sort((a,b)=>b[1]-a[1]);

  ds.forEach(([f])=>{
    x.fillStyle=fill;
    x.strokeStyle=stroke;
    x.lineWidth=dpr;
    x.beginPath();
    x.moveTo(ps[f[0]][0],ps[f[0]][1]);
    for(let j=1;j<4;j++)x.lineTo(ps[f[j]][0],ps[f[j]][1]);
    x.closePath();
    x.fill();
    x.stroke();
  });
}

function sphere(p,C,r){
  const q=proj(p,C);
  if(!q)return;

  const R=Math.max(3*dpr,r*q[3]);
  const g=x.createRadialGradient(
    q[0]-R*.3,q[1]-R*.3,R*.1,
    q[0],q[1],R
  );

  g.addColorStop(0,'#fffbd1');
  g.addColorStop(1,'#ff8617');

  x.fillStyle=g;
  x.beginPath();
  x.arc(q[0],q[1],R,0,Math.PI*2);
  x.fill();
}

function draw(){
  const g=x.createLinearGradient(0,0,0,c.height);
  g.addColorStop(0,'#111a31');
  g.addColorStop(1,'#03050b');
  x.fillStyle=g;
  x.fillRect(0,0,c.width,c.height);

  const C=camera();

  grid(C);
  orbZone(C);

  const headPos=interp(0);
  shadow(headPos,C);

  const list=[];

  S.body.forEach((_,i)=>{
    const p=interp(i);
    const q=proj(p,C);
    if(q)list.push([q[2],i?'b':'h',p,i]);
  });

  const oq=proj(S.orb,C);
  if(oq)list.push([oq[2],'o',S.orb,0]);

  list.sort((a,b)=>b[0]-a[0]);

  list.forEach(it=>{
    if(it[1]==='o'){
      sphere(it[2],C,.23);
    }else{
      cube(
        it[2],
        C,
        it[1]==='h'?.72:.60*(1-it[3]/S.body.length*.32),
        it[1]==='h'?'#ed5925ee':'#d94b2ddd',
        '#ffc070cc'
      );
    }
  });

  pauseMark.style.opacity=S.paused?'0.22':'0';
}

function loop(now){
  const dt=Math.min(.04,(now-last)/1000||0);
  last=now;
  update(dt);
  draw();
  requestAnimationFrame(loop);
}

window.VoxelAnaconda={
  move(key){
    const code='Key'+String(key).toUpperCase();
    const v=dirForKey(code);
    if(v)queue(v);
  },
  setPaused(value){
    S.paused=!!value;
  },
  cameraDelta(yawDelta,pitchDelta){
    S.yaw+=Number(yawDelta)||0;
    S.pitch=clamp(S.pitch+(Number(pitchDelta)||0),.12,1.22);
  },
  setZoom(value){
    cfg.zoom=clamp(Number(value)||1,.60,2.20);
  },
  setSpeed(value){
    cfg.speed=clamp(Number(value)||2,1,8);
  },
  reset(){
    reset();
  },
  state(){
    return{
      paused:S.paused,
      over:S.over,
      score:S.score,
      length:S.body.length,
      moves:S.moves,
      head:S.body[0],
      dir:S.dir,
      zoom:cfg.zoom
    };
  }
};

reset();
requestAnimationFrame(loop);

})();
