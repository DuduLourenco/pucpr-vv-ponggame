package pong.states;

import java.awt.Graphics;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

public class StateManager implements KeyListener {
	
	private static final int numberStates = 3;
	private static States[] states = new States[numberStates];
	private static int currentState = 0;
	
	public static final int FPS = 0, MENU = 1, GAME = 2;
		
	public static void setState(int state) {
		currentState = state;
		states[currentState].init();
	}
	
	public static States getState() {
		return states[currentState];
	}
	
	
	public StateManager() {
		states[0] = new FPSState();
		states[1] = new MenuState();
		states[2] = new GameState();
	}
	
	public void update() {
		states[currentState].update();
	}
	
	public void render(Graphics g) {
		states[currentState].render(g);
	}

	@Override
	public void keyTyped(KeyEvent e) {}

	@Override
	public void keyPressed(KeyEvent e) {
		states[currentState].keyPressed(e.getKeyCode());
	}
	
	@Override
	public void keyReleased(KeyEvent e) {
		states[currentState].keyReleased(e.getKeyCode());	
	}
	
	
	
}
