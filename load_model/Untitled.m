%function multiLed5
clear all;close all;clc;
%2015/3/31
%Consensus Algorithm with multi load ed1th
%problem: this is centralized not distributied

%%%%%%%%%%%%%%%%%%%%%%%% initialize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
type = [1,1,1,2,2,1,3,3,3,3,4,4,4,4];  
%    type      instruction                   formula
%     1         generate                 c = a/2*p^2+b*p
%     2        linear load               c = k*p
%     3       quadratic load             c = a/2*p^2+b*p   
%     4      logarithmic load            c = w*lnx

aa = [0.04,0.06,0.04, 6.5,5.0, 0.063, 0.5,0.4,0.3,0.711, -120,-90,-180,-240];
bb = [1.8,0.6,0.8,  0.001,0.001, 1.905, 21.20,30.00,16.5,21.64, 0.001,0.001,0.001,0.01];
g = (-bb./aa)';     %only useful for quadratic
%  aa is the first parameter of each type formulation
%  bb is the second parameter of each type formulation
%  aa * x^2 + bb * x

Pmin =[60,0,0, -25,-32, 60, -25,-50,-30,-15, -15,-10,-25,-30];
%Pmin =[0,0,0, 0,0, 0, 0,0,0,0, 0,0,0,0];
Pmax =[140,110,150, -45,-55, 80, -45,-70,-60,-30, -35,-20,-40,-50];

e = 0.02;


%ini_P = (Pmin'+Pmin')/2;
ini_R = [3,7,8, 9,1, 3, 4,3,6,2, 8,3,6,2]';
ini_P = [80,60,100, -45,-55, 60,-45,-60,-30,-15, -15,-10,-20,-30]';
for p_i = 1:14
       if type(p_i)==1                  % generater
           c(p_i) = aa(p_i)/2*ini_P(p_i)^2+bb(p_i)*ini_P(p_i);
           
       elseif type(p_i)==2    
           c(p_i) = aa(p_i)*ini_P(p_i);
           
       elseif type(p_i)==3              % quadratic load
           c(p_i) = aa(p_i)/2*ini_P(p_i)^2+bb(p_i)*ini_P(p_i);
           
       elseif type(p_i)==4              % logarithmic load
           c(p_i) = aa(p_i)*log(-ini_P(p_i));
           
       else
           c(p_i) = 0;
       end
end
ini_C = sum(c);
ini_Pd = ini_P;
curr_P = ini_P;
curr_R = ini_R;
curr_Pd = ini_Pd;

%%%%%%%%%%%%%%%%%%%%%%%% D Matrix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
node_D = zeros(14,14);
node_info = [2,4,2,5,4,4,2,1,3,2,2,2,3,2];
for node_i = 1:14
      if node_i == 1
          node_s = [13,14,1,2,3];
      elseif node_i == 2
          node_s = [14,1,2,3,4];
      elseif node_i == 13
          node_s = [11,12,13,14,1];
      elseif node_i == 14
          node_s = [12,13,14,1,2];
      else
          node_s = [node_i-2,node_i-1,node_i,node_i+1,node_i+2];
      end
      d_sum = 0;
      for n_i = 1:5
          if n_i ~=3
              node_D(node_i,node_s(n_i)) = 1/(node_info(node_i)+node_info(node_s(n_i))+1);
              d_sum = d_sum+1/(node_info(node_i)+node_info(node_s(n_i))+1);
          end
      end
      node_D(node_i,node_i)=1-d_sum;
      
end

node_D

%%%%%%%%%%%%%%%%%%%%%%%% Consensus Algorithm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R = [];
P = [];
Pd = [];
Psum = [];
Gsum = [];
X = [];
C = [];
for i = 1:70
   next_R = node_D*curr_R-e*curr_Pd;

   for p_i = 1:14
       if type(p_i)==1                  % generater
           next_P(p_i,1) = 1/aa(p_i)*next_R(p_i)+g(p_i);
           
           if(next_P(p_i,1))>Pmax(p_i)
               next_P(p_i,1) =  Pmax(p_i);
            elseif(next_P(p_i,1))<Pmin(p_i)
               next_P(p_i,1) =  Pmin(p_i); 
           end
           c(p_i) = aa(p_i)/2*next_P(p_i)^2+bb(p_i)*next_P(p_i);
           
       elseif type(p_i)==2              % linear load
           if aa(p_i)<next_R(p_i)
               next_P(p_i,1) = Pmin(p_i);
           else
               next_P(p_i,1) = Pmax(p_i);
           end
           c(p_i) = aa(p_i)*next_P(p_i);
           
       elseif type(p_i)==3              % quadratic load
           next_P(p_i,1) = 1/aa(p_i)*next_R(p_i)+g(p_i);
           if(next_P(p_i,1))<Pmax(p_i)
               next_P(p_i,1) =  Pmax(p_i);
           elseif(next_P(p_i,1))>Pmin(p_i)
               next_P(p_i,1) =  Pmin(p_i); 
           end
           c(p_i) = aa(p_i)/2*next_P(p_i)^2+bb(p_i)*next_P(p_i);
           
       elseif type(p_i)==4              % logarithmic load
           next_P(p_i,1) = aa(p_i)/next_R(p_i);
           if(next_P(p_i,1))<Pmax(p_i)
               next_P(p_i,1) =  Pmax(p_i);
           elseif(next_P(p_i,1))>Pmin(p_i)
               next_P(p_i,1) =  Pmin(p_i); 
           end
           c(p_i) = aa(p_i)*log(-next_P(p_i));
       else
           next_P(p_i,1) = 0;
 
       end
           

   end
   
   next_Pd = node_D*curr_Pd+node_D*(next_P-curr_P);
   Psum = [Psum,sum(next_P)];
   curr_R = next_R;
   curr_P = next_P;
   curr_Pd = next_Pd;
   

   R = [R,next_R];
   P = [P,curr_P];
   Pd = [Pd,next_Pd];
   X = [X,i];
   C = [C,sum(c)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R = [ini_R,R];
P = [ini_P,P];
Pd = [ini_Pd,Pd];
X = [0,X];
Psum = [sum(ini_P),Psum];
C = [ini_C,C];

figure('numbertitle','on','name','total supply-demand mismatch','color','white'),
hold on
xlabel('Number of iterations','FontName','Times New Roman','FontSize',17);
ylabel('Total P','FontName','Times New Roman','FontSize',17);
set(gca,'FontName','Times New Roman','FontSize',17)
set(gcf,'unit','normalized','position',[0.2,0.2,0.64,0.48]);
stairs(X,Psum)
hold off



figure('numbertitle','on','name','Incremental cost','color','white'),
% ylabel('Power')
hold on
s1 = stairs(X,R(1,:),'r-','LineWidth',2.1);
s2 = stairs(X,R(2,:),'g-','LineWidth',2.1);
s3 = stairs(X,R(3,:),'b-','LineWidth',2.1);
s6 = stairs(X,R(6,:),'c-','LineWidth',2.1);
s4 = stairs(X,R(4,:),'r-','LineWidth',2.1);
s5 = stairs(X,R(5,:),'g-','LineWidth',2.1);
s7 = stairs(X,R(7,:),'b-.','LineWidth',2.1);
s8 = stairs(X,R(8,:),'c-.','LineWidth',2.1);
s9 = stairs(X,R(9,:),'k-','LineWidth',2.1);
s10 = stairs(X,R(10,:),'y-','LineWidth',2.1);
s11 = stairs(X,R(11,:),'m:','LineWidth',2.1);
s12 = stairs(X,R(12,:),'r:','LineWidth',2.1);
s13 = stairs(X,R(13,:),'g:','LineWidth',2.1);
s14 = stairs(X,R(14,:),'b:','LineWidth',2.1);
%axis([0,200,5,13]);
xlabel('Number of iterations','FontName','Times New Roman','FontSize',17);
ylabel('Incremental cost','FontName','Times New Roman','FontSize',17);
set(gca,'FontName','Times New Roman','FontSize',17)
set(gcf,'unit','normalized','position',[0.2,0.2,0.64,0.48]);
%legend([s1,s2,s3,s6],'G1','G2','G3','G6')
legend1 = legend([s1,s2,s3,s6],'G1','G2','G3','G6');
set(legend1,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.251546529457112 0.293608862388993 0.412143514259416 0.0655105973025048]);
ah=axes('position',get(gca,'position'),'visible','off');

legend2 = legend(ah,[s7,s8,s9,s10],'Qu7','Qu8','Qu9','Qu10');
set(gca,'FontName','Times New Roman','FontSize',17);
set(legend2,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.160288105305314 0.145091031311038 0.34590616375345 0.0655105973025048]);
ah1=axes('position',get(gca,'position'),'visible','off');

legend3 = legend(ah1,[s4,s5],'Li4','Li5');
set(gca,'FontName','Times New Roman','FontSize',17)
set(legend3,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.70887622149835 0.29447655748233 0.138979370249724 0.0655105973025048]);
ah2=axes('position',get(gca,'position'),'visible','off');

legend4 = legend(ah2,[s11,s12,s13,s14],'Log11','Log12','Log13','Log14');
set(gca,'FontName','Times New Roman','FontSize',17)
set(legend4,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.51452225841475 0.149967886962101 0.364820846905537 0.0655105973025048]);

hold off


figure('numbertitle','on','name','Power P','color','white'),
hold on
s1 = stairs(X,P(1,:),'r-','LineWidth',2.1);
s2 = stairs(X,P(2,:),'g-','LineWidth',2.1);
s3 = stairs(X,P(3,:),'b-','LineWidth',2.1);
s6 = stairs(X,P(6,:),'c-','LineWidth',2.1);
s4 = stairs(X,P(4,:),'r-','LineWidth',2.1);
s5 = stairs(X,P(5,:),'g-','LineWidth',2.1);
s7 = stairs(X,P(7,:),'b-.','LineWidth',2.1);
s8 = stairs(X,P(8,:),'c-.','LineWidth',2.1);
s9 = stairs(X,P(9,:),'k-','LineWidth',2.1);
s10 = stairs(X,P(10,:),'y-','LineWidth',2.1);
s11 = stairs(X,P(11,:),'m:','LineWidth',2.1);
s12 = stairs(X,P(12,:),'r:','LineWidth',2.1);
s13 = stairs(X,P(13,:),'g:','LineWidth',2.1);
s14 = stairs(X,P(14,:),'b:','LineWidth',2.1);
axis([0,70,-120,130]);
xlabel('Number of iterations','FontName','Times New Roman','FontSize',17);
ylabel('Power','FontName','Times New Roman','FontSize',17);
set(gca,'FontName','Times New Roman','FontSize',17)
set(gcf,'unit','normalized','position',[0.2,0.2,0.64,0.48]);
%legend([s1,s2,s3,s6],'G1','G2','G3','G6')
legend1 = legend([s1,s2,s3,s6],'G1','G2','G3','G6');
set(legend1,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.152197995255161 0.542163775683794 0.412143514259422 0.0655105973025048]);
ah=axes('position',get(gca,'position'),'visible','off');

legend2 = legend(ah,[s7,s8,s9,s10],'Qu7','Qu8','Qu9','Qu10');
set(gca,'FontName','Times New Roman','FontSize',17);
set(legend2,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.138301134621275 0.160046056419108 0.34590616375345 0.0587219343696027]);
ah1=axes('position',get(gca,'position'),'visible','off');

legend3 = legend(ah1,[s4,s5],'Li4','Li5');
set(gca,'FontName','Times New Roman','FontSize',17)
set(legend3,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.7137622149837 0.541104688503527 0.138979370249726 0.0655105973025048]);
ah2=axes('position',get(gca,'position'),'visible','off');

legend4 = legend(ah2,[s11,s12,s13,s14],'Log11','Log12','Log13','Log14');
set(gca,'FontName','Times New Roman','FontSize',17)
set(legend4,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.51452225841475 0.149967886962101 0.364820846905537 0.0655105973025048]);

hold off


figure('numbertitle','on','name','Pd','color','white'),
hold on
s1 = stairs(X,Pd(1,:),'r-','LineWidth',2.1);
s2 = stairs(X,Pd(2,:),'g-','LineWidth',2.1);
s3 = stairs(X,Pd(3,:),'b-','LineWidth',2.1);
s6 = stairs(X,Pd(6,:),'c-','LineWidth',2.1);
s4 = stairs(X,Pd(4,:),'r-','LineWidth',2.1);
s5 = stairs(X,Pd(5,:),'g-','LineWidth',2.1);
s7 = stairs(X,Pd(7,:),'b-.','LineWidth',2.1);
s8 = stairs(X,Pd(8,:),'c-.','LineWidth',2.1);
s9 = stairs(X,Pd(9,:),'k-','LineWidth',2.1);
s10 = stairs(X,Pd(10,:),'y-','LineWidth',2.1);
s11 = stairs(X,Pd(11,:),'m:','LineWidth',2.1);
s12 = stairs(X,Pd(12,:),'r:','LineWidth',2.1);
s13 = stairs(X,Pd(13,:),'g:','LineWidth',2.1);
s14 = stairs(X,Pd(14,:),'b:','LineWidth',2.1);

xlabel('Number of iterations','FontName','Times New Roman','FontSize',17);
ylabel('Mismatch','FontName','Times New Roman','FontSize',17);
set(gca,'FontName','Times New Roman','FontSize',17)
set(gcf,'unit','normalized','position',[0.2,0.2,0.64,0.48]);
%legend([s1,s2,s3,s6],'G1','G2','G3','G6')
legend1 = legend([s1,s2,s3,s6],'G1','G2','G3','G6');
set(legend1,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.250732197209558 0.786865124431382 0.412143514259417 0.0655105973025048]);
ah=axes('position',get(gca,'position'),'visible','off');

legend2 = legend(ah,[s7,s8,s9,s10],'Qu7','Qu8','Qu9','Qu10');
set(gca,'FontName','Times New Roman','FontSize',17);
set(legend2,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.1586594408102 0.152798160405451 0.34590616375345 0.0655105973025048]);
ah1=axes('position',get(gca,'position'),'visible','off');

legend3 = legend(ah1,[s4,s5],'Li4','Li5');
set(gca,'FontName','Times New Roman','FontSize',17)
set(legend3,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.713762214983693 0.783879254977512 0.138979370249724 0.0655105973025048]);
ah2=axes('position',get(gca,'position'),'visible','off');

legend4 = legend(ah2,[s11,s12,s13,s14],'Log11','Log12','Log13','Log14');
set(gca,'FontName','Times New Roman','FontSize',17)
set(legend4,'Orientation','horizontal','YColor',[1 1 1],'XColor',[1 1 1],...
    'Position',[0.535694896851231 0.149967886962101 0.364820846905536 0.0655105973025048]);
hold off

figure('numbertitle','on','name','total supply-demand mismatch','color','white'),
hold on
xlabel('Number of iterations','FontName','Times New Roman','FontSize',17);
ylabel('Cost','FontName','Times New Roman','FontSize',17);
set(gca,'FontName','Times New Roman','FontSize',17)
set(gcf,'unit','normalized','position',[0.2,0.2,0.64,0.48]);
stairs(X,C)
hold off