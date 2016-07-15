// dos melodías intentan alcanzar una melodía de referencia
// a través de mutaciones a melodías aleatorias

// tempo
33::ms => dur tick;
tick * 4 => dur beat;

// esta es la  base de posibilidades
[ 64, 66, 68, 71, 73] @=> int base[];

// esta es la secuencia de referencia
[ 68, 66, 64, 71, 73] @=> int goal[];

6 => int C; // numero de melodías BUG:: se desborda el array si son mas de goal
int melodyNumber;
Osc s[C];
Pan2 p[C];
ADSR e[C];
JCRev r[C];
Gain master;

// se inicializan los arreglos
int sequence[C][goal.cap()];

// se crean los generadores de sonido
fun void melodies(float octave, Osc Osc)
{
  for( 0 => int i; i < C; i++ )
  {
    s[i] => e[i] => r[i] => master => p[i] => dac;
    ( 0.03::second, 0.01::second, (1.0/C), 0.01::second ) => e[i].set;
    r[i].mix(0.09);
    s[i].gain(0.1/C);
    e[i].keyOff();
  }
}

// funcion notas aleatorias
fun int createRandomNote()
{
  Math.random2(10, 127) => int note;
  return note;
}

// se llenan las secuencias con notas aleatorias
for (0 => int i; i < C; i++)
  {
    for( 0 => int ii; ii < goal.cap(); ii++)
      {
        createRandomNote() => sequence[i][ii];
        <<< sequence[i][ii] >>>;
      }
  }

// --- suena secuencias
fun void playSequences(int sequenceToPlay)
{
  // TODO: dividir el panorama en el número de melodías con la función
  //       para cambio de rango.
  Math.random2f(-1.0, 1.0) => p[sequenceToPlay].pan;
  // defino límite 
  sequence[sequenceToPlay].cap() => int limit;
  // selecciona nota y la suena 
  while(true)
  {
    for( 0 => int i; i < limit; i++ )
    {
      Std.mtof(sequence[sequenceToPlay][i]) => s[sequenceToPlay].freq;
      e[sequenceToPlay].keyOn();
      beat => now;
      e[sequenceToPlay].keyOff();
    }
    2*beat => now; // silencio para diferenciar la melodía (estético)

    // revisa si lo logró comparando los arrays
    for( 0 => int i; i < C; i++ )
    {
      0 => int matched;
      for( 0 => int ii; ii < limit; ii++ )
      {
        if( sequence[i][ii] == goal[ii] )
        {
          matched + 1 => matched;
        }
      }
      <<< "            ---- matched = ",matched >>>;
      if( matched == limit )
      {
        <<< "Secuencia ", i, " completa " >>>;
      }
    }

    // según una probabilidad, genera una mutación en una nota
    intChance(Math.random2(20, 60), 1, 0) => int chance;
    if(chance == 1)
    {
      mutate();
    }
  }
}

// función para probabilidad
fun int intChance( int percent, int value1, int value2)
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

// funcion para mutar los arreglos aleatorios
// TODO: la base de la mutación debe adaptarse a un nuevo arreglo que
//       ya contiene las notas encontradas
fun int mutate()
{
  Math.random2(0, C-1) => int seqToMutate;
  Math.random2(0, base.cap()-1) => int noteToMutate;
  // se evalua si la nota existente es igual a la melodía de referencia,
  if(sequence[seqToMutate][noteToMutate] == goal[noteToMutate])
  {
    <<< ": ** encontró coincidencia**  ",  goal[noteToMutate], "\n" >>>;
  }
  else
  {
    base[Math.random2(0, base.cap()-1)] => sequence[seqToMutate][noteToMutate];
    <<< "muta melodía ",seqToMutate,"\n">>>;
  }
}

// ---------- 
SinOsc myOsc;

// inicializa los osciladores
spork~  melodies(1.0,  myOsc);

// ejecuta y suena las secuencias
for( 0 => int i; i < C; i++)
{
  spork~ playSequences(i);
}

// mantiene vivos los spork
while(true){ 10::ms => now;}
