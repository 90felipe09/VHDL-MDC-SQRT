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

-- Descrição estrutural Alto nível FD e UC
architecture square_arch of square is
	component square_fd is
		port
		(
			X : 		in signed(7 downto 0);
			clk : 	in bit;
			itera : 	in bit;
			done : 	in bit;
			reset : 	in bit;
			
			square : out signed (7 downto 0);
			QX : 		out signed (7 downto 0);
			S : 		out signed (7 downto 0);
		);
	end component;
	
	component square_uc is
		port
		(
			square : in signed(7 downto 0);
			QX : 		in signed(7 downto 0);
			clk : 	in bit;
			
			itera : 	out bit;
			done : 	out bit;
		);
	end component;
	
	signal itera, donesig, squaresig, qxsig;
	
	begin
		fd: square_fd port map(X, clk, itera, donesig, reset, squaresig, qxsig, S);
		uc: square_uc port map(sqauresig, qxsig, clk, reset, itera, done);
		
end architecture;


-- Descrição da raiz quadrada UC

library ieee;
use ieee.numeric_bit.all;

-- @brief square_uc
---- Estado: IMPLEMENTADO.
entity square_uc is
  port (
		square : in signed(7 downto 0);
		QX : 		in signed(7 downto 0);
		clk : 	in bit;
		
		itera : 	out bit;
		done : 	out bit;
  );
  
end entity square_uc;

-- Descrição comportamental de UC
---- Estado: IMPLEMENTADO.
architecture square_uc_arch of square is
	my_process : process(clk) is
		begin:
			if (clk'event and clk='1') then
				if (square <= QX) then 
					itera <= '1';
					concluiu <= '0';
				else
					itera <= '0';
					concluiu <= '1';
				end if;
			end if;
		end process my_process;
		
end architecture;


-- Descrição da raiz quadrada DF

library ieee;
use ieee.numeric_bit.all;

-- @brief square_df
---- Estado: Não implementado.
entity square_df is
  port (
		X : 		in signed(7 downto 0);
		clk : 	in bit;
		itera : 	in bit;
		done : 	in bit;
		reset : 	in bit;
		
		square : out signed (7 downto 0);
		QX : 		out signed (7 downto 0);
		S : 		out signed (7 downto 0);
  );
  
end entity square_df;

-- Descrição Estrutural de FD
---- Estado: Implementado.
architecture square_df_arch of square is
	component reg8bit is
    port (
      D : in signed (7 downto 0);
		clk : in bit;
		load : in bit;
		shiftR : in bit;
		
		Do : out signed (7 downto 0);
    );
	end component;
	
	component somador is
    port (
      A : in signed (7 downto 0);
		B : in signed (7 downto 0);
		sel : in bit;
		
		R : out signed (7 downto 0);
    );
	end component;
	
	component mux is
    port (
      A : in signed (7 downto 0);
		B : in signed (7 downto 0);
		sel : in bit;
		
		S : out signed (7 downto 0);
    );
	end component;
	
	component buffertristate is
    port (
      A : in signed (7 downto 0);
		sel : in bit;
		
		S : out signed (7 downto 0);
    );
	end component;
	-- s: saida
	--- M: Multiplexador
	--- R: Registrador
	--- S: Somador
	---- S: Square
	---- D: Delta
	---- F: Final
	signal sMS, sMD, sMF, sRS, sRD, sSA, sSB;
	
	begin:
		RA: reg8bit port map (X, clk, itera, '0', QX);
		RS: reg8bit port map(sMS, clk, itera, '0', sRS);
		RD: reg8bit port map(sMD, clk, itera, done, sRD);
		MS: mux port map(sSA, "00000001", reset, sMS);
		MD: mux port map(sSB, "00000010", reset, sMD);
		MF: mux port map("00000010", "00000001", sMF);
		SA: somador port map(sRS, sRD, '0', sSA);
		SB: somador port map(sRD, sMF, done, sSB);
		BF: buffertristate port map(sSB, done, S);
		
		square <= sRS;
		
end architecture;

library ieee;
use ieee.numeric_bit.all;

-- @brief reg8bit
---- Estado: Não implementado.
entity reg8bit is
  port (
		D : in signed (7 downto 0);
		clk : in bit;
		load : in bit;
		shiftR : in bit;
		
		Do : out signed (7 downto 0);
  );
  
end entity square_df;

architecture
	signal Q : signed (7 downto 0);
	begin
		process(clk,load)
			begin
				if (clk'event = '1' and clk ='1') then
					if (load = '1') then
						Q <= D;
					elsif (shiftR = '1' and load = '0') then
						Q <= Q slr 1;
					end if;
				end if;
			end process;
		
		

end architecture;













