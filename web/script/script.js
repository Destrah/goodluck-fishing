let gameOver = false;

// ----
// Game
// ----
  
  // -------
  // Seaweed
  // -------
  
async function StartSeaweedAnimation(){
    let seaweed = [];
    const canvas = document.querySelector('[data-element="seaweed"]');
    canvas.width = canvas.clientWidth * 2;
    canvas.height = canvas.clientHeight * 2;
    const context = canvas.getContext('2d');
    let interval;
  
    function animationLoop() {
      if (!gameOver) {
          clearCanvas();
          seaweed.forEach(seaweed => seaweed.draw());
      } else {
        clearInterval(interval)
      }
    }
  
    function clearCanvas() {
      context.clearRect(0, 0, canvas.width, canvas.height);
    }
  
    class Seaweed {
      constructor(segments, spread, xoff) {
        this.segments = segments;
        this.segmentSpread = spread;
        this.x = 0;
        this.xoff = xoff;
        this.y = 0;
        this.radius = 1;
        this.sin = Math.random() * 10;
      }
  
      draw() {
        context.beginPath();
        context.strokeStyle="#143e5a";
        context.fillStyle="#143e5a";
        context.lineWidth=2;
        for (let i = this.segments; i >= 0; i--) {
          if (i === this.segments) {
            context.moveTo(
              Math.sin(this.sin + i) * i/2.5 + this.xoff,
              canvas.height + (-i * this.segmentSpread),
            );
          } else {
            context.lineTo(
              Math.sin(this.sin + i) * i/2.5 + this.xoff,
              canvas.height + (-i * this.segmentSpread),
            );
          }
          // context.arc(Math.sin(this.sin + i) * 10 + 30, this.y + (this.segmentSpread * i), this.radius, 0, 2*Math.PI); 
        }
        context.stroke();
  
        this.sin += 0.05;
      }
    }
  
    seaweed.push(new Seaweed(6, 8, 25));
    seaweed.push(new Seaweed(8, 10, 35));
    seaweed.push(new Seaweed(4, 8, 45));
  
    interval = setInterval(animationLoop, 10);
}
  
  // -----------------
  // Reel line tension
  // -----------------

async function StartLineTensionAnimation() {
    let line = null;
    const canvas = document.querySelector('[data-element="reel-line-tension"]');
    canvas.width = canvas.clientWidth * 2;
    canvas.height = canvas.clientHeight * 2;
    const context = canvas.getContext('2d');
    let interval;
  
    function animationLoop() {
      if (!gameOver) {
          clearCanvas();
          line.draw();
          line.animate();
      
          requestAnimationFrame(animationLoop);
      } else {
        clearInterval(interval);
      }
    }
  
    function clearCanvas() {
      context.clearRect(0, 0, canvas.width, canvas.height);
    }
  
    class Line {
      constructor() {
        this.tension = 0;
        this.tensionDirection = 'right';
      }
  
      draw() {
        context.beginPath();
        context.strokeStyle="#18343d";
        context.lineWidth=1.3;
        context.moveTo(canvas.width, 0);
        context.bezierCurveTo(
          canvas.width,canvas.height/2 + this.tension,
          canvas.width/2,canvas.height + this.tension,
          0,canvas.height
        );
        context.stroke();
      }
  
      animate() {
        if (document.body.classList.contains('collision')) {
          if (this.tension > -30) this.tension -= 8;
        } else {
          if (this.tension < 0) this.tension += 4;
        }
      }
    }
  
    line = new Line();
    interval = setInterval(animationLoop, 10);
}
  
  // -------
  // Bubbles
  // -------

async function StartBubbleAnimation() {
    let bubbles = {};
    let bubblesCreated = 0;
    const canvas = document.querySelector('[data-element="bubbles"]');
    canvas.width = canvas.clientWidth * 2;
    canvas.height = canvas.clientHeight * 2;
    const context = canvas.getContext('2d');
    let interval;
  
    function animationLoop() {
      if (!gameOver) {
          clearCanvas();
          Object.keys(bubbles).forEach(bubble => bubbles[bubble].draw());
      } else {
        clearInterval(interval)
      }
    }
  
    function clearCanvas() {
      context.clearRect(0, 0, canvas.width, canvas.height);
    }
  
    class Bubble {
      constructor() {
        this.index = Object.keys(bubbles).length;
        this.radius = Math.random() * (6 - 2) + 2;
        this.y = canvas.height + this.radius;
        this.x = canvas.width * Math.random() - this.radius;
        this.sin = (this.style > 0.5) ? 0 : 5;
        this.style = Math.random();
        this.childAdded = false;
        this.speed = 1;
        this.sway = Math.random() * (0.03 - 0.01) + 0.01;
        this.swayDistance = Math.random() * (canvas.width - canvas.width/2) + canvas.width/2;
      }
  
      draw() {
        context.beginPath();
        context.strokeStyle="#abe2f9";
        context.lineWidth=2;
        context.arc(this.x + this.radius, this.y + this.radius, this.radius, 0, 2*Math.PI);
        context.stroke();
        this.x = (Math.sin(this.sin) * this.swayDistance) + this.swayDistance - this.radius;
        this.sin += this.sway;
        this.y -= this.speed;
  
        if (this.y + this.radius < 0) {
          delete bubbles[this.index];
        }
  
        if (this.y < canvas.height * 0.6) {
          if (!this.childAdded) {
            bubbles[bubblesCreated] = new Bubble();
            bubblesCreated++;
            this.childAdded = true;
          }
        }
      }
    }
  
    bubbles[bubblesCreated] = new Bubble();
    bubblesCreated++;
  
    interval = setInterval(animationLoop, 10);
};

async function StartFishMiniGame(barSize, barSpeed, fishSpeed, progDecRate, progIncRate) {
    gameOver = false;
    // --------------
    // Animation loop
    // --------------
    let interval;
  
    function animationLoop() {
      if (!gameOver) {
        indicator.updatePosition();
        indicator.detectCollision();
        progressBar.updateUi();
        progressBar.detectGameEnd();
        fish.updateFishPosition();
      } else {
        clearInterval(interval);
        finishGame();
      }
    }
  
    // ---------
    // Indicator
    // ---------
  
    class Indicator {
      constructor() {
        this.indicator = document.querySelector('.indicator');
        this.indicator.style.height = `${barSize}%`
        this.indicator.style.top = `${100 - barSize}%`
        this.height = this.indicator.clientHeight;
        this.y = 0;
        this.velocity = 0;
        this.acceleration = 0;
        this.topBounds = (gameBody.clientHeight * -1) + (gameBody.clientHeight * (barSize / 100) + 2);
        this.bottomBounds = 0;
      }
  
      applyForce(force) {
        this.acceleration += force;
      }
  
      updatePosition() {
        this.velocity += this.acceleration;
        if (keyPressed) {
            if (this.velocity < -barSpeed) {
                this.velocity = -barSpeed;
            }
        } else {
            if (this.velocity > barSpeed) {
                this.velocity = barSpeed;
            }
        }

        this.y += this.velocity;
        
        //  Reset acceleration
        indicator.acceleration = 0;
  
        // Change direction when hitting the bottom + add friction
        if (this.y > this.bottomBounds) {
          this.y = 0;
          this.velocity *= 0.5;
          this.velocity *= -0.5;
        }
  
        // Prevent from going beyond the top
        // Don't apply button forces when beyond the top
        // console.log(indicator.y, this.topBounds);
        if (indicator.y < this.topBounds) {
          indicator.y = this.topBounds;
          indicator.velocity = 0;
        } else {
          if (keyPressed) {
            indicator.applyForce(-0.35);
          }
        }
  
        // Apply constant force
        indicator.applyForce(0.3);
       
        // Update object position
        this.indicator.style.transform = `translateY(${this.y}px)`;
      }
  
      detectCollision() {
        if (
          fish.y < this.y && fish.y > this.y - this.height ||
          fish.y - fish.height < this.y && fish.y - fish.height > this.y - this.height
        ) {
          progressBar.fill();
          document.body.classList.add('collision');
        } else {
          progressBar.drain();
          document.body.classList.remove('collision');
        }
      }
    }
  
    // ----
    // Fish
    // ----
  
    class Fish {
      constructor() {
        this.fish = document.querySelector('.fish');
        this.height = this.fish.clientHeight;
        this.y = (Math.random() * ((this.fish.clientHeight + 10) - gameBody.clientHeight) + gameBody.clientHeight) * -1;
        this.direction = null;
        this.randomPosition = null;
        this.randomCountdown = null;
        this.speed = fishSpeed;
      }
  
      resetPosition() {
        this.y = (Math.random() * ((this.fish.clientHeight + 10) - gameBody.clientHeight) + gameBody.clientHeight) * -1;
        this.speed = fishSpeed;
      }
  
      updateFishPosition() {
        if (!this.randomPosition || this.randomCountdown < 0) {
          this.randomPosition = Math.ceil(Math.random() * (gameBody.clientHeight - this.height)) * -1;
          this.randomCountdown = Math.abs(this.y - this.randomPosition);
          this.speed = Math.abs(Math.random() + fishSpeed);
        };
  
        if (this.randomPosition < this.y) {
          this.y -= this.speed;
        } else {
          this.y += this.speed;
        }
        
        this.fish.style.transform = `translateY(${this.y}px)`;
        this.randomCountdown -= this.speed;
      }
    }
  
    // ------------
    // Progress bar
    // ------------
  
    class ProgressBar {
      constructor() {
        this.wrapper = document.querySelector('.progress-bar');
        this.progressBar = this.wrapper.querySelector('.progress-gradient-wrapper');
        this.progress = 40;
      }
  
      reset() {
        this.progress = 40;
      }
      drain() {
        if (this.progress > 0) this.progress -= progDecRate;
        if (this.progress < 1) {
            this.progress = 0
            gameOver = true;
            fetch(`https://rush-fishing/FinishMiniGame`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({cancelled: false, failed: true}),
            });
        };
      }
  
      fill() {
        if (this.progress < 100) this.progress += progIncRate;
      }
  
      detectGameEnd() {
        if (this.progress >= 100) {  
          gameOver = true;
        }
      }
  
      updateUi() {
        this.progressBar.style.height = `${this.progress}%`
      }
    }
  
    // -----------
    // Application
    // -----------
  
    const gameBody = document.querySelector('.game-body');
    let keyPressed = false;
    const indicator = new Indicator();
    const progressBar = new ProgressBar();
    const fish = new Fish();
  
    // ------------
    // Mouse events
    // ------------
  
    //window.addEventListener('mousedown', indicatorActive);
    //window.addEventListener('mouseup', indicatorInactive);
    window.addEventListener('keydown', indicatorActive);
    window.addEventListener('keyup', indicatorInactive);
    //window.addEventListener('touchstart', indicatorActive);
    //window.addEventListener('touchend', indicatorInactive);
  
    function indicatorActive (event) {
      if (!keyPressed && event.code === "Space") {
        keyPressed = true;
        document.body.classList.add('indicator-active');
      }
    }
  
    function indicatorInactive () {
      if (keyPressed) {
        keyPressed = false;
        document.body.classList.remove('indicator-active');
      }
    }
  
    // ----------
    // Finish game
    // ----------

    function finishGame() {
        console.log("Removing minigames")
        //window.removeEventListener('mousedown', indicatorActive)
        //window.removeEventListener('mouseup', indicatorInactive);
        window.removeEventListener('keydown', indicatorActive);
        window.removeEventListener('keyup', indicatorInactive);
        //window.removeEventListener('touchstart', indicatorActive);
        //window.removeEventListener('touchend', indicatorInactive);

        document.body.style.display = 'none';

        document.body.classList.remove('indicator-active');

        fetch(`https://rush-fishing/FinishMiniGame`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({cancelled: false, failed: false}),
        });
    }
  
    // ----------
    // Reset game
    // ----------
  
    const niceCatch = document.querySelector('.nice-catch');
    const perfect = document.querySelector('.perfect');
    const successButton = document.querySelector('.success');
    const game = document.querySelector('.game');
    successButton.addEventListener('click', resetGame);
  
    function resetGame() {
      progressBar.reset();
      fish.resetPosition();
  
      successButton.removeAttribute('style');
      niceCatch.removeAttribute('style');
      perfect.removeAttribute('style');
      game.removeAttribute('style');
  
      gameOver = false;
  
      interval = setInterval(animationLoop, 10);
    }
  
    // ----------------
    // Success timeline
    // ----------------
  
    function successTimeline() {
      TweenMax.set(".success", {display: 'flex'});
      TweenMax.set(".nice-catch", {y: 50});
      TweenMax.set(".perfect", {perspective:800});
      TweenMax.set(".perfect", {transformStyle:"preserve-3d"});
      TweenMax.set(".perfect", {rotationX:-90});
  
      const tl = new TimelineMax({paused: true})
      .to('.game', 0.2, {opacity: 0})
      .to('.success', 0.5, {ease: Power3.easeOut, opacity: 1}, 'ending')
      .to('.nice-catch', 0.5, {ease: Power3.easeOut, y: 0}, 'ending')
      .to('.perfect', 3, {ease: Elastic.easeOut.config(1, 0.3), rotationX: 0}, '+=0.2');
  
      return tl;
    }
  
    // -------------
    // Initiate loop
    // -------------
    StartBubbleAnimation();
    StartLineTensionAnimation();
    StartSeaweedAnimation();
  
    interval = setInterval(animationLoop, 10);
}

document.addEventListener("DOMContentLoaded", (event) => {
    window.addEventListener("message", function (event) {
        if (event.data.action === "start") {
            document.body.style.display = 'flex';
            let barSize = event.data.barSize ? event.data.barSize : 7.8;
            let barSpeed = event.data.barSpeed ? event.data.barSpeed : 1.4;
            let fishSpeed = event.data.fishSpeed ? event.data.fishSpeed : 0.45;
            let progDecRate = event.data.progDecRate ? event.data.progDecRate : 0.1;
            let progIncRate = event.data.progIncRate ? event.data.progIncRate : 0.255;
            StartFishMiniGame(barSize, barSpeed, fishSpeed, progDecRate, progIncRate);
        } else if (event.data.action === "cancel") {
            gameOver = true;
        }
    });
});