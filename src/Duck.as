package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import flashx.textLayout.compose.TextFlowLine;
	
	public class Duck extends Sprite
	{
		
		//添加瞄准镜
		var miao:MovieClip;
		//瞄准镜的有效杀伤半径;
		var ratio:int;
		
		var swimmingDuck:Duck;
//		var bullet:MovieClip;
		
		//冻结时间
		var cd:int = 0;
		
		//鸭子的数组
		var duckArr:Array;
		
		//分数数值
		var sorce:int = 0;
		
		//子弹剩余数量
		static var count:int = 10; 
		
		//显示“正在装弹”
		var rb:MovieClip;
		
		var sorceText:TextField = new TextField();
		
		public function Duck()
		{
			super();
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
//			trace(stage.fullScreenWidth)
			
			//添加背景
			var bg:MovieClip = new Bg();
			stage.addChild(bg);
			
			
			
			//位移(注册点为中心点)
			bg.x = stage.fullScreenWidth/2;
			bg.y = stage.fullScreenHeight/2;
			//缩放
			bg.width = stage.fullScreenWidth;
			bg.height = stage.fullScreenHeight;
			
			//添加瞄准镜
			miao = new Target();
			ratio = miao.width>>1;
			stage.addChild(miao);
			//stage.addChild(sorce);
			
			
			//让瞄准镜一直跟随鼠标
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
//			if(count > 0) {
			stage.addEventListener(MouseEvent.CLICK,shouDuck);
//				trace(count);
//			} else {
//				trace("装弹");
//			}
			


			
			//隐藏原有的鼠标
//			Mouse.hide();
			
			//////////////////////////////开启游戏主循环///////////////////////////////////
			//1.使用机器器
//			var timer:Timer = new Timer(20);
//			timer.addEventListener(TimerEvent.TIMER,mainUpdate);
//			timer.start();
			//2.给舞台绑定帧监听
			stage.addEventListener(Event.ENTER_FRAME,mainUpdate);
			
			duckArr = new Array();
		}
		
		/**
		 * 游戏的主循环方法
		 * */
		private function mainUpdate(e:Event = null):void{
			//显示分数
			
			sorceText.text = "得分"+ String(sorce) + "\n" + "剩余子弹数" + String(count) +"\n乐乐我想你"; 
			sorceText.border=true;
			stage.focus=sorceText;
			stage.addChild(sorceText);
			cd++;
			//隔一段时间就飞一只鸭子
			if(cd==24){
				cd=0;
				//创建一只鸭子
				var duck:MovieClip = new FlayDuck();
				stage.addChild(duck);
				//让鸭子的初始位置在屏幕的1/4到3/4的位置
				duck.x = Math.random()*stage.fullScreenWidth;
				duck.y = stage.fullScreenHeight*0.9;
				duck.zhouyou = 123;
				//把这个鸭子放入数组
				duckArr.push(duck);
				//由于在AS3中，MOvieclip是一个动态类，所以可以给mc对象动态的添加属性，甚至是方法
				duck.speedY = 5;
				duck.speedX = -2+Math.random()*5;
			}
			
			//每一帧都让所有的鸭子运动
			for(var i:int=0;i<duckArr.length;i++){
				var d:FlayDuck = duckArr[i];
				d.y -= d.speedY;
				d.x += d.speedX;
				//当鸭子飞出屏幕时，要做两件事情
				if(d.y<0){
					//1.从duckArr中移除
					duckArr.splice(i,1);//从第i个位置开始，移除1位        duckArr.splice(0,duckArr.length)
					i--;
					//2.从stage上移除
					d.stop();
					d.parent.removeChild(d);
				}
			}
		}
		
		
		
		
		
		protected function onMouseMove(event:MouseEvent):void
		{
			//让瞄准镜一直跟随鼠标
			miao.x = stage.mouseX;
			miao.y = stage.mouseY;
		}
		
		protected function shouDuck(event:MouseEvent):void
		{
			if(count <= 0) {
				rb = new RB();
				stage.addChild(rb);
				rb.x = 170;
				rb.y = 20;
				setTimeout(fullOfBullet ,5000);
				//移除监听器
				stage.removeEventListener(MouseEvent.CLICK,shouDuck);
			} else {
				//发射一发子弹
				var bullet:MovieClip = new Bullet();
				stage.addChild(bullet);
				bullet.x = stage.mouseX;
				bullet.y = stage.mouseY;
				bullet.addEventListener(Event.ENTER_FRAME,onBulletFrame);
				count--;
			}
			
		}
		
		private function fullOfBullet():void
		{
			stage.removeChild(rb);
			count = 10;
			//把监听器加回去
			stage.addEventListener(MouseEvent.CLICK,shouDuck);
		}
		
		protected function onBulletFrame(event:Event):void
		{
			var bullet:MovieClip = event.target as MovieClip;
			//如果子弹的当前帧等于最后帧
			if(bullet.currentFrame==bullet.totalFrames){
				//判断子弹是否击中鸭子
				isBulletHitDuck(bullet);
				//移除子弹				
				bullet.stop();
				bullet.removeEventListener(Event.ENTER_FRAME,onBulletFrame);
				bullet.parent.removeChild(bullet);
				
			}
		}
		
		//判断子弹是否打中鸭子
		private function isBulletHitDuck(bullet:MovieClip):void{
			//遍历鸭子
			for(var i:int=0;i<duckArr.length;i++){
				//获得每只鸭子的位置
				var d:MovieClip = duckArr[i];
				//计算鸭子与子弹之前的距离
				var distance:int = Math.sqrt((d.x-bullet.x)*(d.x-bullet.x)+(d.y-bullet.y)*(d.y-bullet.y));
				//判断这个距离是否符合碰撞的距离
				if(distance<=ratio){
					sorce++;
					//鸭子消失
					duckArr.splice(i,1);
					i--;
					d.parent.removeChild(d);
					//创建一个掉落的鸭子的动画，并且让这个动画只播放一次后从舞台上移除
					var fall:MovieClip = new FallDuck();
					stage.addChild(fall);
					fall.x = d.x;
					fall.y = d.y;
					fall.addEventListener(Event.ENTER_FRAME,fallEnterFrame);
				}
			}
		}
		
		protected function fallEnterFrame(event:Event):void
		{
			 var fall:MovieClip = event.target as MovieClip;
			 if(fall.currentFrame==fall.totalFrames){
			 	fall.stop();
				fall.removeEventListener(Event.ENTER_FRAME,fallEnterFrame);
				fall.parent.removeChild(fall);
			 }
		}
		
		
	}
}