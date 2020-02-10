DropZone dropZone;
ArrayList<NextScreen> nextScreens;

PVector fallingBlockPos;

PVector mpos, ampos;
ArrayList<PVector> selectedArr;

void setup() {
	size(501, 801);
	selectedArr = new ArrayList<PVector>();
	
	dropZone = new DropZone(0, 0, width-100-1, height-1);
	
	nextScreens = new ArrayList<NextScreen>();
	nextScreens.add(new NextScreen(width-100-1+floor(25/2), floor(25/2), 75, 75));
	nextScreens.add(new NextScreen(width-100-1+35, 110, 50, 50));
	nextScreens.add(new NextScreen(width-100-1+35, 185, 50, 50));
	nextScreens.add(new NextScreen(width-100-1+35, 260, 50, 50));
	
	resetFallingBlock();
	
	frameRate(60);
}

void draw() {
	background(0);
	if(frameCount % 30 == 0) {
		fallingBlockPos = dropZone.fall(fallingBlockPos);
	}
	for (NextScreen ns : nextScreens) {
		ns.render(false);
	}
	dropZone.render();
}

public abstract class Screen {
	public int x, y, xs, ys;
	
	public Screen(int x, int y, int xs, int ys) {
		this.x = x;
		this.y = y;
		this.xs = xs;
		this.ys = ys;
	}
	
	public void render() {
		push();
			noFill(); stroke(255);
			rect(this.x, this.y, this.xs, this.ys);
		pop();
	}
}

public class NextScreen extends Screen {
	Block nextBlock;
	public NextScreen(int x, int y, int xs, int ys) {
		super(x, y, xs, ys);
		this.nextBlock = new Block(this.x, this.y, this.xs, this.ys);
		this.nextBlock.contents = dropZone.fillBlock();
	}
	
	public void render(Boolean text) {
		super.render();
		if (text) {
			push();
				textAlign(LEFT); stroke(255); fill(255); textSize(16);
				text("Next", this.x, this.y+this.ys+16);
			pop();
		}
		push();
			textAlign(CENTER); textSize(16);
			text(this.nextBlock.contents, (this.x+this.xs/2), (this.y+this.ys/2)+5);
		pop();
		
	}
}

public class DropZone extends Screen {
	public Block[][] blocks;
	public int bh, bw;
	
	public DropZone(int x, int y, int xs, int ys) {
		super(x, y, xs, ys);
		this.blocks = new Block[8][16];
		this.bw = this.xs/this.blocks.length;
		this.bh = this.ys/this.blocks[0].length;
		for (int i = 0; i < this.blocks.length; i++) {
			for (int j = 0; j < this.blocks[i].length; j++) {
				this.blocks[i][j]
					= new Block(i, j, this.bw, this.bh);
				// this.blocks[i][j].contents = this.fillBlock();
			}
		}
	}

	public void render() {
		if (ampos != null) {
			// Try to add to list
			addToSelectedList(new PVector(floor(mouseX/this.bw), floor(mouseY/this.bh)));
			try {
				for (PVector pv : selectedArr) {
					this.blocks[floor(pv.x)][floor(pv.y)].highlight = true;
				}
			} catch(ArrayIndexOutOfBoundsException aiobe) { }
		}
		for (Block[] barr : this.blocks) {
			for (Block b : barr) {
				b.render();
			}
		}
		super.render();
	}
	
	
	public String fillBlock() {
		return str(char(floor(random(65, 91))));
	}
	
	public PVector fall(PVector fbpos) {
		try {
			Block b = this.blocks[floor(fbpos.x)][floor(fbpos.y)];
			if (this.blocks[floor(fbpos.x)][floor(fbpos.y+1)].contents == "") {
				this.blocks[floor(fbpos.x)][floor(fbpos.y+1)].contents = b.contents;
				this.blocks[floor(fbpos.x)][floor(fbpos.y)].contents = "";
				fbpos.y += 1;
				return fbpos;
			} else {
				resetFallingBlock();
				return fallingBlockPos;
			}
		} catch(IndexOutOfBoundsException iobe) {
			resetFallingBlock();
			return fallingBlockPos;
		}
	}
	
	public void mergeFall(PVector pv) {
		try {
			if (this.blocks[floor(pv.x)][floor(pv.y+1)].contents == "") {
				this.blocks[floor(pv.x)][floor(pv.y+1)].contents = this.blocks[floor(pv.x)][floor(pv.y)].contents;
				this.blocks[floor(pv.x)][floor(pv.y)].contents = "";
				this.mergeFall(new PVector(pv.x, pv.y+1));
			} else {
				return;
			}
		} catch(ArrayIndexOutOfBoundsException aiobe) {
			return;
		}
	}
	public PVector moveFalling(PVector fbps, int dir) {
		if (fbps.x + dir < 0 || fbps.x + dir >= this.blocks.length) return fbps;
		this.blocks[floor(fbps.x + dir)][floor(fbps.y)].contents
			= this.blocks[floor(fbps.x)][floor(fbps.y)].contents;
		this.blocks[floor(fbps.x)][floor(fbps.y)].contents = "";
		fbps.x += dir;
		return fbps;
	}
}

public class Block {
	public int x, y, xs, ys;
	public String contents = "";
	
	public boolean highlight = false;
	
	Block(int x, int y, int xs, int ys) {
		this.x = x;
		this.y = y;
		this.xs = xs;
		this.ys = ys;
	}
	
	public void render() {
		push();
			if (this.highlight) {
				strokeWeight(3);
				stroke(255); noFill();
			} else {
				stroke(100, 100); noFill();
			}
			textAlign(CENTER);
			text(this.contents, (this.x*this.xs+this.xs/2), (this.y*this.ys+this.ys/2)+5);
			rect(this.x*xs, this.y*ys, this.xs, this.ys);
			this.highlight = false;
		pop();
	}
}

public void mousePressed() {
	if (mouseButton == LEFT) {
		mpos  = new PVector(mouseX, mouseY);
		ampos = new PVector(floor(mpos.x/dropZone.bw), floor(mpos.y/dropZone.bh));
		addToSelectedList(new PVector(ampos.x, ampos.y));
	}
	else if (mouseButton == RIGHT) {
		if (selectedArr.size() > 0) { return; }
		mpos  = new PVector(mouseX, mouseY);
		ampos = new PVector(floor(mpos.x/dropZone.bw), floor(mpos.y/dropZone.bh));
		if (dropZone.blocks[floor(ampos.x)][floor(ampos.y)].contents != "") {
			dropZone.blocks[floor(ampos.x)][floor(ampos.y)].contents = nextScreens.get(0).nextBlock.contents;
			resetNext();
		}
	}
}

public void mouseReleased() {
	if (mouseButton == LEFT) {
		if (mpos == null || ampos == null) return;
		
		mergeBlocks(selectedArr);
		selectedArr.clear();
		mpos = null;
		ampos = null;
	}
	else if(mouseButton == RIGHT) {
		selectedArr.clear();
		mpos = null;
		ampos = null;
	}
}

public void addToSelectedList(PVector npv) {
	// Test Out Of Bounds
	if (npv.x < 0 || npv.x >= dropZone.blocks.length) return;
	if (npv.y < 0 || npv.y >= dropZone.blocks[0].length) return;
	if (dropZone.blocks[floor(npv.x)][floor(npv.y)].contents == "") return;
	
	try {
		// Remove last if equals to second to last
		PVector slpv = selectedArr.get(selectedArr.size()-2);
		if (npv.x == slpv.x && npv.y == slpv.y) {
			selectedArr.remove(selectedArr.size()-1);
			return;
		}
		
		// Longer than 4?
		if (selectedArr.size()+1 > 4) return;
		// Add if Not exists
		for (PVector pv : selectedArr) {
			if (pv.x == npv.x && pv.y == npv.y) { return; }
		}
		selectedArr.add(npv);
	}
	catch(Exception ex) {
		// Longer than 4?
		if (selectedArr.size()+1 > 4) return;
		// Add if Not exists
		for (PVector pv : selectedArr) {
			if (pv.x == npv.x && pv.y == npv.y) { return; }
		}
		selectedArr.add(npv);
	}
}

public void mergeBlocks(ArrayList<PVector> pvl) {
	if (pvl.size() == 0 || pvl.size() == 1) return;
	for (int i = 1; i < pvl.size(); i++) {
		PVector ppv = pvl.get(i-1);
		PVector pv  = pvl.get(i);
		dropZone.blocks[floor(pv.x)][floor(pv.y)].contents 
			= dropZone.blocks[floor(ppv.x)][floor(ppv.y)].contents
			+ dropZone.blocks[floor(pv.x)][floor(pv.y)].contents;
		dropZone.blocks[floor(ppv.x)][floor(ppv.y)].contents = "";
		// dropZone.blocks[floor(ppv.x)][floor(ppv.y)].contents = nextScreens.get(i-1).nextBlock.contents;
		// nextScreens.get(i-1).nextBlock.contents = "";
	}
	dropZone.mergeFall(pvl.get(pvl.size()-1));
	// resetNext();
}

public void resetNext() {
	//reset next blocks
	do {
		for (int i = 0; i < nextScreens.size()-1; i++) {
			nextScreens.get(i).nextBlock.contents = nextScreens.get(i+1).nextBlock.contents;
		}
		nextScreens.get(nextScreens.size()-1).nextBlock.contents = dropZone.fillBlock();
	} while(nextScreens.get(0).nextBlock.contents == "");
}

public void resetFallingBlock() {
	fallingBlockPos = new PVector(3, 0);
	dropZone.blocks[3][0] = new Block(3, 0, dropZone.bw, dropZone.bh);
	dropZone.blocks[3][0].contents = nextScreens.get(0).nextBlock.contents;
	resetNext();
}

void keyPressed() {
	if (key == 'a' || key == 'A') {
		dropZone.moveFalling(fallingBlockPos, -1);
	}
	else if (key == 'd' || key == 'D') {
		dropZone.moveFalling(fallingBlockPos, 1);
	}
	else if (key == ' ') {
		dropZone.mergeFall(fallingBlockPos);
		resetFallingBlock();
	}
}