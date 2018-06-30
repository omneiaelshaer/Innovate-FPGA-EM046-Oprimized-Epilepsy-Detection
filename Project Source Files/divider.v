module divider(Q,M,Quo,Remi);
parameter input_width = 16;

	input[input_width-1:0] Q;
	input[input_width-1:0] M;
	output[input_width-1:0] Quo;
	output[input_width-1:0]Remi;

	reg[input_width-1:0] Quo=0;
	reg[input_width-1:0] Remi=0;
	reg[input_width-1:0] a1,b1;
	reg[input_width-1:0] p1;
	integer i;

always@(Q or M) 
begin

	a1=Q;
	b1=M;	
	p1=0;
	Quo=0;

	if(a1[input_width-1]==1)
		a1=0-a1;
	if(b1[input_width-1]==1)
		b1=0-b1;
		
	if(b1[input_width-1]==1) begin
		if(a1[input_width-1]==1) begin
			b1=0-b1;
			a1=0-b1;
		end
	end
		
for(i=0;i<input_width;i=i+1) begin
	p1={p1[input_width-2:0],a1[input_width-1]};
	a1[input_width-1:1]=a1[input_width-2:0];
	p1=p1-b1;
	if(p1[input_width-1]==1) begin
		a1[0]=0;
		p1=p1+b1;
		end
	else
		a1[0]=1;
	end

	if (Q[input_width-1]==1) begin
     		 if (M[input_width-1]==0) begin
       			Quo=0-a1;
       			Remi=0-p1;
     		 end
    	end
	
	if (Q[input_width-1]==0) begin
    		  if (M[input_width-1]==1) begin
      			 Quo=0-a1;
      			 Remi=p1;
    		  end
        end

	if (Q[input_width-1]==1) begin
     		 if (M[input_width-1]==1) begin
      			 Quo=a1;
		         Remi=0-p1;
    		 end
    	end
 
	if (Q[input_width-1]==0) begin
     		 if (M[input_width-1]==0) begin
      			 Quo=a1;
		         Remi=p1;
    		 end
    	end
end
endmodule

 

