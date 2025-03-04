import tkinter as tk

class SoftballScorebook:
    def __init__(self):
        # Game state
        self.current_bases = {'1': None, '2': None, '3': None}  # Track player names on bases
        self.outs = 0
        self.runs = 0
        self.inning = 1
        self.count = {'balls': 0, 'strikes': 0}
        self.players = []  # List of player names
        self.batting_order = []  # Current batting order
        self.current_batter_index = 0  # Index of the current batter in the batting order (starts at 0)
        self.score_log = []  # Log of all plays
        self.pitch_log = []  # Log of pitches for the current batter
        
        # GUI setup
        self.root = tk.Tk()
        self.root.title("Softball Scorebook")
        self.canvas = tk.Canvas(self.root, width=400, height=400)
        self.canvas.pack()
        
        # Start the game loop
        self.setup_players()
        self.draw_diamond()
        self.game_loop()

    def draw_diamond(self):
        """Draw the diamond and update player positions."""
        self.canvas.delete("all")  # Clear the canvas
        
        # Draw the diamond
        self.canvas.create_polygon(200, 50, 350, 200, 200, 350, 50, 200, fill="white", outline="black")
        self.canvas.create_line(200, 50, 200, 350)  # Vertical line
        self.canvas.create_line(50, 200, 350, 200)  # Horizontal line
        
        # Draw base labels
        self.canvas.create_text(200, 30, text="Home", font=("Arial", 10))
        self.canvas.create_text(370, 200, text="1st", font=("Arial", 10))
        self.canvas.create_text(200, 370, text="2nd", font=("Arial", 10))
        self.canvas.create_text(30, 200, text="3rd", font=("Arial", 10))
        
        # Draw players on bases
        if self.current_bases['1']:
            self.canvas.create_oval(330, 180, 350, 200, fill="blue")
            self.canvas.create_text(340, 190, text=self.current_bases['1'][0], fill="white")
        if self.current_bases['2']:
            self.canvas.create_oval(190, 330, 210, 350, fill="blue")
            self.canvas.create_text(200, 340, text=self.current_bases['2'][0], fill="white")
        if self.current_bases['3']:
            self.canvas.create_oval(30, 180, 50, 200, fill="blue")
            self.canvas.create_text(40, 190, text=self.current_bases['3'][0], fill="white")
        
        # Display game info
        self.canvas.create_text(200, 380, text=f"Inning: {self.inning} | Outs: {self.outs} | Runs: {self.runs}", font=("Arial", 12))
        self.canvas.create_text(200, 395, text=f"Count: {self.count['balls']}B {self.count['strikes']}S", font=("Arial", 12))

    def get_yes_no(self, prompt):
        """Prompt the user for a yes/no answer."""
        while True:
            answer = input(prompt + " (y/n): ").lower()
            if answer in ['y', 'n']:
                return answer == 'y'
            print("Invalid answer. Please use 'y' or 'n'")
    
    def record_pitch(self, pitch_type):
        """Record a pitch and display the count."""
        if pitch_type == 'ball':
            self.count['balls'] += 1
            self.pitch_log.append('.')
        elif pitch_type == 'swinging_strike':
            self.count['strikes'] += 1
            self.pitch_log.append('x')
        elif pitch_type == 'called_strike':
            self.count['strikes'] += 1
            self.pitch_log.append('c')
        elif pitch_type == 'foul':
            if self.count['strikes'] < 2:
                self.count['strikes'] += 1
            fielder = input("Enter the closest fielder's position (2, 3, 5, 7, 9): ")
            self.pitch_log.append(fielder)
        print(f"Pitch log: {''.join(self.pitch_log)}")
    
    def update_bases(self, from_base, to_base, player_name=None):
        """Update player positions on the bases."""
        if from_base in ['1', '2', '3']:
            self.current_bases[from_base] = None
        if to_base in ['1', '2', '3']:
            self.current_bases[to_base] = player_name
        elif to_base.upper() == 'H':
            self.runs += 1
        else:
            print("Invalid base specified. No changes made to the bases.")
        self.draw_diamond()  # Redraw the diamond after updating bases
    
    def setup_players(self):
        """Set up the batting order."""
        num_players = int(input("Enter the number of players on the team: "))
        for i in range(num_players):
            name = input(f"Enter the name of player {i+1}: ")
            self.players.append(name)
            self.batting_order.append(name)
        print("Batting order set up successfully!")
        self.current_batter_index = 0
    
    def record_play(self, notation, batter_name):
        """Log the play."""
        self.score_log.append(f"Inning {self.inning}: {batter_name}: {notation}")
    
    def handle_batter(self):
        """Handle the current batter."""
        batter_name = self.batting_order[self.current_batter_index]
        print(f"\nCurrent batter: {batter_name} (Player #{self.current_batter_index + 1})")
        self.pitch_log = []  # Reset pitch log for the new batter
        
        while True:
            pitch_result = input("\nPitch result:\n1. Ball\n2. Swinging strike\n3. Called strike\n4. Foul\n5. Wild throw\n6. In play\n> ")
            if pitch_result == '1':
                self.record_pitch('ball')
            elif pitch_result == '2':
                self.record_pitch('swinging_strike')
            elif pitch_result == '3':
                self.record_pitch('called_strike')
            elif pitch_result == '4':
                self.record_pitch('foul')
            elif pitch_result == '5':
                print("Wild throw occurred!")
                self.handle_wild_throw()
                continue  # Allow the batter to take another turn
            elif pitch_result == '6':
                break
            
            if self.count['balls'] >= 4:
                print("Base on balls (BB).")
                self.update_bases('B', '1', batter_name)
                self.record_play("BB", batter_name)
                self.handle_runners()
                break
            if self.count['strikes'] >= 3:
                print("Strikeout recorded.")
                notation = "KC" if 'c' in self.pitch_log else "K2"
                self.outs += 1
                self.record_play(notation, batter_name)
                break
        
        if self.count['strikes'] < 3 and self.count['balls'] < 4:
            self.handle_in_play(batter_name)
        
        # Reset the count for the next batter
        self.count = {'balls': 0, 'strikes': 0}
        
        # Move to the next batter after handling the current one
        self.current_batter_index = (self.current_batter_index + 1) % len(self.batting_order)
    
    def handle_in_play(self, batter_name):
        """Handle the result of a ball put in play."""
        outcome = input("\nPlay result:\n1. Hit\n2. Error\n3. HBP\n4. Wild Pitch\n5. Other\n> ")
        if outcome == '1':
            hit_type = input("Hit type:\n1. Single\n2. Double\n3. Triple\n4. HR\n5. Bunt single\n> ")
            if hit_type == '1':
                bases = '1'
                notation = "*"
            elif hit_type == '2':
                bases = '2'
                notation = "--*"
            elif hit_type == '3':
                bases = '3'
                notation = "---*"
            elif hit_type == '4':
                bases = 'H'
                notation = "----*"
            elif hit_type == '5':
                pos = input("Fielder position (1-9): ")
                bases = '1'
                notation = f"B{pos}"
            self.update_bases('B', bases, batter_name)
        elif outcome == '2':
            error_type = input("Error type:\n1. Fielding error (E*)\n2. Throwing error (WT*)\n3. Receiving error (*-E*)\n4. Catching error (MF*)\n> ")
            if error_type == '1':
                pos = input("Fielder position (1-9): ")
                notation = f"E{pos}"
            elif error_type == '2':
                pos = input("Fielder position (1-9): ")
                notation = f"WT{pos}"
            elif error_type == '3':
                pos1 = input("Fielder position (1-9): ")
                pos2 = input("Fielder position (1-9): ")
                notation = f"{pos1}-E{pos2}"
            elif error_type == '4':
                pos = input("Fielder position (1-9): ")
                notation = f"MF{pos}"
            self.update_bases('B', '1', batter_name)
        elif outcome == '3':
            self.update_bases('B', '1', batter_name)
            notation = "HPB"
        elif outcome == '4':
            print("Wild pitch occurred!")
            notation = "KWP"
            self.handle_wild_pitch()
        elif outcome == '5':
            other_type = input("Other safe play:\n1. KE2\n2. KWP\n3. K2-E3\n> ")
            if other_type == '1':
                notation = "KE2"
            elif other_type == '2':
                notation = "KWP"
            elif other_type == '3':
                notation = "K2-E3"
            self.update_bases('B', '1', batter_name)
        
        self.record_play(notation, batter_name)
        print(f"{notation} recorded")
        self.handle_runners()
    
    def handle_wild_throw(self):
        """Handle runners advancing due to a wild throw."""
        for base in ['3', '2', '1']:
            runner_name = self.current_bases[base]
            if runner_name:
                to_base = str(int(base) + 1) if base != '3' else 'H'
                self.update_bases(base, to_base, runner_name)
                print(f"{runner_name} advanced to {to_base} on the wild throw.")
        
        # Check for stolen bases after the wild throw
        if self.get_yes_no("Did any runner attempt to steal a base?"):
            self.handle_steal()
    
    def handle_steal(self):
        """Handle stolen bases."""
        for base in ['1', '2', '3']:
            runner_name = self.current_bases[base]
            if runner_name and self.get_yes_no(f"Did {runner_name} attempt to steal?"):
                to_base = str(int(base) + 1) if base != '3' else 'H'
                self.update_bases(base, to_base, runner_name)
                print(f"{runner_name} stole {to_base}.")
    
    def handle_runners(self):
        """Advance runners manually."""
        while self.get_yes_no("\nAdvance runners?"):
            from_base = input("From base (1-3): ")
            to_base = input("To base (2/H): ").upper()
            
            if from_base not in ['1', '2', '3'] or to_base not in ['2', '3', 'H']:
                print("Invalid base specified. Please try again.")
                continue
            
            runner_name = self.current_bases[from_base]
            if runner_name is None:
                print(f"No runner on base {from_base}.")
                continue
            
            self.update_bases(from_base, to_base, runner_name)
            print(f"Runner advanced {from_base}→{to_base}")
    
    def game_loop(self):
        """Main game loop."""
        max_innings = int(input("Enter the maximum number of innings: "))
        while self.inning <= max_innings:
            self.handle_batter()
            if self.outs >= 3:
                if self.get_yes_no("End inning?"):
                    self.inning += 1
                    self.outs = 0
                    self.current_bases = {'1': None, '2': None, '3': None}
                else:
                    self.outs = 0
            if self.get_yes_no("End game?"):
                break
        print("\nGAME OVER - FINAL SCORE")
        print(f"Runs: {self.runs}")
        print("\nScore Log:")
        for entry in self.score_log:
            print(entry)
        self.root.mainloop()

if __name__ == "__main__":
    game = SoftballScorebook()
