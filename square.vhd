--------------------------------------------------------------------------------
--! 5307474 Bruno de Carvalho Albertini
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

-- @brief Raiz Quadrada
entity square is
  port (
    X     : in  signed(7 downto 0); -- entrada
    S     : out signed(7 downto 0); -- saida
    reset : in  bit; -- reset ativo alto assíncrono
    done  : out bit; -- alto quando terminou de calcular
    clk   : in  bit
  );
end entity square;

architecture comp of square is
  component square_fd is
    port (
      resposta : out signed (7 downto 0);
		estado   : in  bit_vector (1 downto 0);
		squareAux 	: out signed (7 downto 0);
		realizaOp : in bit;
		opRealizada : out bit;
    );
  end component;
  component square_uc is
    port (

    );
  end component;
  signal QA, itera, square : bit;
begin

end architecture;


entity square_fd is
  port (
	resposta : out signed (7 downto 0);
	estado   : in  bit_vector (1 downto 0);
	squareAux 	: out signed (7 downto 0);
	realizaOp : in bit;
	opRealizada : out bit;
  );
end entity square_fd;

architecture fd of square_fd is
	signal delta : signed (7 downto 0);
	opRealizadaAux : bit;

begin
	proc_square : process (realizaOp, estado) is
		begin:
			if (realizaOp'event and realizaOp = '1') then
				opRealizadaAux <= '0';
				opRealizada <= '0';
			end if;
			
			if (opRealizadaAux = '0') then
				case estado is
					when "00" =>
						squareAux <= "00000001";
						delta <= "00000011";
						resposta <= "00000000";
						
					when "01" =>
						squareAux <= squareAux + delta;
						delta <= (delta + "00000010");
						resposta <= "00000000";
						
					when "10" =>
						squareAux <= squareAux;
						delta <= delta;
						resposta <= ((delta/2) - 1);
						
					when others =>
						squareAux <= squareAux;
						delta <= delta;
						resposta <= resposta;
						
				end case;
				
				opRealizadaAux <= '1';
				opRealizada <= '1';
			end if;
		end process proc_square;
	

end architecture;

entity square_uc is
  port (
		state : out bit_vector (1 downto 0);
      A : in  signed (7 downto 0);
		square : in  signed (7 downto 0);
		opRealizada : in bit;
		realizaOp : out bit;
      clk   : in  bit
		rst : in bit;
		done : out bit;
  );
end entity square_uc;

architecture uc of square_uc is
	type estados is (E1, E2, E3);
	signal estado : estados
		
begin
	my_process : process (clk, rst)
		begin
			if (reset = '1') then
				estado <= E1;
			elsif (clk'event and clk = '1' and opRealizada = '1') then
				case estado is
					when E1 =>
						if (square = "00000001") then estado <= E2;
						else estado <= E1;
						end if;
						
					when E2 =>
						if (square <= A) then estado <= E2;
						else estado <= E3;
						end if;
				end case;
			end if;
		end process my_process;	
		
	with estado select 
		state <= "00" when E1,
					"01" when E2,
					"10" when E3,
					"11" when others;
					
	with estado select 
		realizaOp <=	"00" when E1,
							"01" when E2,
							"10" when E3,
							"11" when others;
					
	with estado select 
		done <=  "00" when E1,
					"01" when E2,
					"10" when E3,
					"11" when others;
		
	
end architecture;
