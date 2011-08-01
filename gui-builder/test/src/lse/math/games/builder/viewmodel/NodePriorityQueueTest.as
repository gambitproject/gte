package lse.math.games.builder.viewmodel 
{		
	import org.flexunit.Assert;
	import lse.math.games.builder.model.Node;
	
	/**
	 * @author alfongj
	 */
	public class NodePriorityQueueTest
	{
		private var queue:NodePriorityQueue;
		private var n1:Node;
		private var n11:Node;
		private var n12:Node;
		private var n13:Node;
		private var n121:Node;
		private var n1211:Node;
		private var n12111:Node;
		private var n111:Node;
		private var n131:Node;
		
		[Before]
		public function init():void
		{
			queue = new NodePriorityQueue();
			
			//n1 is the top node, and its children are n1X, whose children are n1XY and the same for the rest...
			n1= new Node(null, 1);
			n11 = new Node(null, 11);
			n12 = new Node(null, 12);
			n13 = new Node(null, 13);
			n1.addChild(n11);
			n1.addChild(n12);
			n1.addChild(n13);
			n121 = new Node(null, 121);
			n12.addChild(n121);
			n1211 = new Node(null, 1211);
			n121.addChild(n1211);
			n12111 = new Node(null, 12111);
			n1211.addChild(n12111);
			n111 = new Node(null, 111);
			n11.addChild(n111);
			n131 = new Node(null, 131);
			n13.addChild(n131);
		}

		[Test]
		public function testInsertionAndExtraction():void
		{
			Assert.assertTrue(queue.isEmpty);
			
			Assert.assertEquals(0,queue.push(n13));

			queue.push(n1);

			Assert.assertEquals(2,queue.push(n131));

			queue.push(n111);

			Assert.assertEquals(4,queue.length);
			Assert.assertFalse(queue.isEmpty);
			Assert.assertEquals(1,queue.front.number);
			Assert.assertEquals(131,queue.back.number);
			
			Assert.assertEquals(1, queue.push(n12));
			Assert.assertEquals(1, queue.push(n11));
		}
		
		[Test]
		public function testRemoval():void
		{
			Assert.assertEquals(-1, queue.remove(n1));
			
			queue.push(n1);
			queue.push(n11);
			queue.push(n12);
			queue.push(n13);
			queue.push(n1211);
			queue.push(n12111);

			Assert.assertEquals(0, queue.remove(n1));
			Assert.assertEquals(4, queue.remove(n12111));
			
			Assert.assertEquals(2, queue.remove(n13));
			
			Assert.assertEquals(-1, queue.remove(n13));
			
			Assert.assertEquals(1211, queue.pop().number);
			
			Assert.assertEquals(11, queue.shift().number);
		}
		
		[Test]
		public function testContains():void
		{
			Assert.assertFalse(queue.contains(n1));
			
			queue.push(n1);
			queue.push(n11);
			queue.push(n12);
			queue.push(n13);
			queue.push(n1211);
			queue.push(n12111);

			Assert.assertTrue(queue.contains(n1));
			Assert.assertFalse(queue.contains(n121));
			Assert.assertTrue(queue.contains(n13));
			Assert.assertTrue(queue.contains(n12111));
			queue.remove(n13);
			Assert.assertFalse(queue.contains(n13));
		}
	}
}