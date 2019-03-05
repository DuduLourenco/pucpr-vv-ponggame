package pong.input;

import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

public class KeyManager implements KeyListener {

	private boolean[] keys = new boolean[256];
	public static boolean w, s, up, down, speed;
	
	public void update() {
		w = keys[KeyEvent.VK_W];
		s = keys[KeyEvent.VK_S];
		up = keys[KeyEvent.VK_UP];
		down = keys[KeyEvent.VK_DOWN];
		speed = keys[KeyEvent.VK_END];
	}
	
	@Override
	public void keyPressed(KeyEvent e) {
		if(e.getKeyCode() < 0 || e.getKeyCode() > 255)
			return;
		
		keys[e.getKeyCode()] = true;
	}
	
	@Override
	public void keyReleased(KeyEvent e) {
		if(e.getKeyCode() < 0 || e.getKeyCode() > 255)
			return;
		
		keys[e.getKeyCode()] = false;
		
	}
		
	@Override
	public void keyTyped(KeyEvent e) {}

}
