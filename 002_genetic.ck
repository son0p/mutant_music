
// 4 => int C; //number of bees
// SinOsc s[C]; // Oscillators and Pans for each bee
// Pan2 p[C];
// ADSR e[C];
// NRev r[C];
// Gain gBees;
// for ( 0 => int ii ; ii < C ; ++ii ) {
//     s[ii] => e[ii] => r[ii] => gBees => p[ii] => dac;
//     ( 0.01::second, 0.01::second, (1.0/C), 0.6::second ) => e[ii].set;
//     r[ii].mix(0.09);
//     s[ii].gain(0.3/C);
//      => s[ii].freq;
// }



SinOsc s;
Pan2 p;
JCRev r;
0.05 => s.gain;
-1.0 => p.pan;
0.03 => r.mix;

SinOsc s2;
Pan2  p2;
JCRev r2;
1.0 => p2.pan;
0.05 => s2.gain;
0.03 => r2.mix;
s => r => p => dac;
s2 => r2 => p2 => dac;

[ 64, 66, 68, 71, 73] @=> int nucleotides[];

int seq[5];

[ 66, 64, 68, 73, 71 ] @=> int sequence[];
[ 66, 64, 68, 73, 71 ] @=> int sequence2[];



function int intChance( int percent, int value1, int value2)
{
    int percentArray[100];
    for( 0 => int i; i < 100; i++)
        {
            if( i < percent ) value1 => percentArray[i];
            if( i >= percent ) value2 => percentArray[i];
        }
    percentArray[Math.random2(0, percentArray.cap()-1)] => int selected;
    return selected;
}

//
function int mutate(){
    nucleotides[Math.random2(0, sequence.cap()-1)] =>  sequence[Math.random2(0, nucleotides.cap()-1)];
}
function int mutate2(){
    nucleotides[Math.random2(0, sequence2.cap()-1)] =>  sequence2[Math.random2(0, nucleotides.cap()-1)];
}

function void playSequence (int sequence[]){
    while (true){
        for( 0 => int i; i < (sequence.cap()-1); i++){
            Std.mtof(sequence[i]) => s.freq;
            222::ms => now;
        }
        intChance(30, 1, 0) => int chance;
        if(chance == 1)
            {
                mutate();
                <<< "mutate">>>;
            }
    }
}

function void playSequence2 (int seq2[]){
    while (true){
        for( 0 => int i; i < (sequence2.cap()-1); i++){
            Std.mtof(seq2[i])  => s2.freq;
            222::ms => now;
        }
        intChance(10, 1, 0) => int chance;
        if(chance == 1)
            {
                mutate2();
                <<< "mutate2">>>;
            }
    }
}


spork~  playSequence(sequence);
spork~  playSequence2(sequence2);
while(true){ 10::ms => now;}
