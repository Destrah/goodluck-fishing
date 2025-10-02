exports("RandomNumber", (min, max, decimalPlaces) => {
    if (decimalPlaces === undefined || decimalPlaces === null) {
        decimalPlaces = 0
    }
    var rand = Math.random()*(max-min) + min;
    var power = Math.pow(10, decimalPlaces);
    return Math.floor(rand*power) / power;
});

exports("NormalDist",  (min, max, skew, decimalPlaces) => {
    if (decimalPlaces === undefined || decimalPlaces === null) {
        decimalPlaces = 1
    }
    let u = 0, v = 0;
    while(u === 0) u = Math.random() //Converting [0,1) to (0,1)
    while(v === 0) v = Math.random()
    let num = Math.sqrt( -2.0 * Math.log( u ) ) * Math.cos( 2.0 * Math.PI * v )
    
    num = num / 10.0 + 0.5 // Translate to 0 -> 1
    if (num > 1 || num < 0) 
      num = NormalDist(min, max, skew) // resample between 0 and 1 if out of range
    else{
      num = Math.pow(num, skew) // Skew
      num *= max - min // Stretch to fill range
      num += min // offset to min
    }
    var power = Math.pow(10, decimalPlaces);
    return Math.floor(num*power) / power;
  });