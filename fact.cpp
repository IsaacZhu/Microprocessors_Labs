#include <stdio.h>
#include <string.h> 

int array[20];
int bitnum=1;
int result[20];
void oneplace(int k);
void tenplace();

void fact(){
	int k,i;
	for (k=19;k>0;--k){
		if (k>=10){
			oneplace(k%10);
			tenplace();
		}
		else{
			oneplace(k);
		}
		memcpy(array,result,20*sizeof(int));
		memset(result,0,20*sizeof(int));
	}
}

void oneplace(int k){
	int i,j;
	for (i=0;i<bitnum;i++){					//one place
		result[i]=array[i]*k;
	}
	for (j=0;j<bitnum;++j){
		if (result[j]>=10){
			result[j+1]+=(result[j]/10);
			result[j]=result[j]%10;
		}
	}
	if (result[bitnum]!=0) /*bitnum=j+1;*/bitnum++;
}

void tenplace(){
	int i,j;
	for (i=0;i<bitnum;i++){					//ten place
		result[i+1]+=array[i];				
	}
	for (j=0;j<bitnum;++j){
		if (result[j]>=10){
			result[j+1]+=(result[j]/10);
			result[j]=result[j]%10;
		}
	}
	bitnum++;
}

int main(){
	memset(array,0,20*sizeof(int));
	memset(result,0,20*sizeof(int));
	array[0]=1;
	fact();
	int i;
	for (i=bitnum;i>=0;--i){
		printf("%d ",array[i]);
	}
	printf("\n");
} 
