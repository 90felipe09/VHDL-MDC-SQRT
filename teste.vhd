	library ieee;
	use ieee.numeric_bit.all;


	-- @brief Raiz Quadrada
	entity square is
	  port (
		 X     : in  signed(7 downto 0); -- entrada
		 S     : out signed(7 downto 0); -- saida
		 reset : in  bit; -- reset ativo alto assíncrono
		 --done  : out bit; -- alto quando terminou de calcular
		 clk   : in  bit;
		 q : out signed(1 downto 0)
	  );
	end entity square;


	architecture arch of square is
	--Adicionando componentes
	  component square_con is
	  port (
			aletb : in  bit;
			loadSaida : out  bit;
			loadSquare : out  bit;
			loadDelta  : out  bit;
			setIn      : out  bit;
			setSub     : out  bit;
			reset : in  bit; -- reset ativo alto assíncrono
			--done  : out bit; -- alto quando terminou de calcular
			clk   : in  bit;
			q : out signed(1 downto 0)
			);
	  end component;

	  component square_fd is
	  port (
			X     : in  signed(7 downto 0); -- entrada
			S     : out signed(7 downto 0); -- saida
			aletb : out  bit;
			loadSaida : in  bit;
			loadSquare : in  bit;
			loadDelta  : in  bit;
			setIn      : in  bit;
			setSub     : in  bit;
			clk   : in  bit;
			reset : in bit
	  );
	  end component;

	  signal aletb, loadSaida, loadSquare, loadDelta,setIn,setSub: bit;

	begin

		fd: square_fd port map(X,S,aletb,loadSaida,loadSquare,loadDelta,setIn,setSub,clk,reset);
		uc: square_con port map(aletb,loadSaida,loadSquare,loadDelta,setIn,setSub,reset,clk,q);
	end architecture;

	library ieee;
	use ieee.numeric_bit.all;

	--Unidade de controle
	entity square_con is
	  port (
			aletb : in  bit;
			loadSaida : out  bit;
			loadSquare : out  bit;
			loadDelta  : out  bit;
			setIn      : out  bit;
			setSub     : out  bit;
			reset : in  bit; -- reset ativo alto assíncrono
			--done  : out bit; -- alto quando terminou de calcular
			clk   : in  bit;
			q : out signed(1 downto 0)
	  );
	end entity square_con;

	architecture uc of square_con is

		type st is (caso_a,caso_b,caso_c,fim);
		signal  estado : st;
	begin
		 asm : process(clk,reset,aletb)
		 begin
			if reset = '1' then
			  estado <= caso_a;
			elsif(clk'event and clk = '1') then
			  case estado is
				 when caso_a =>
				 if aletb  = '1' then
					estado <= caso_b;
				 else
					estado <= caso_c;
				 end if;

				 when caso_b =>
				 if aletb  = '1' then
					estado <= caso_b;
				 else
					estado <= caso_c;
				 end if;

				 when caso_c =>
				 estado <= fim;

				 when fim =>
					estado <= fim;
				 end case;
			  end if;
			end process;

			process(estado)
			begin
			 case estado is
			 when caso_a =>
				loadSaida  <= '0';
				loadSquare <= '1';
				loadDelta  <= '1';
				setIn      <= '1';
				setSub     <= '0';
				--done       <= '0';
				q <= "00";
			 when caso_b =>
				loadSaida  <= '0';
				loadSquare <= '1';
				loadDelta  <= '1';
				setIn      <= '0';
				setSub     <= '0';
				--done       <= '0';
				q <= "01";
			 when caso_c =>
				loadSaida  <= '1';
				loadSquare <= '0';
				loadDelta  <= '0';
				setIn      <= '0';
				setSub     <= '1';
				--done       <= '0';
				q <= "10";
			 when fim =>
				loadSaida  <= '0';
				loadSquare <= '0';
				loadDelta  <= '0';
				setIn      <= '0';
				setSub     <= '0';
				--done       <= '1';
				q <= "11";
			 end case;
			end process;

	end architecture;


	library ieee;
	use ieee.numeric_bit.all;
	--Fluxo de dados

	entity square_fd is
	  port (
			X     : in  signed(7 downto 0); -- entrada
			S     : out signed(7 downto 0); -- saida
			aletb : out  bit;
			loadSaida : in  bit;
			loadSquare : in  bit;
			loadDelta  : in  bit;
			setIn      : in  bit;
			setSub     : in  bit;
			clk   : in  bit;
			reset : in bit
	  );
	end entity square_fd;

	architecture fd of square_fd is

	--componentes
		 component somador8bits
	  port (
		 A : in  signed(7 downto 0);
		 B : in  signed(7 downto 0);
		 S : out signed(7 downto 0)
	  );
	  end component somador8bits;

	  component somaSub8Bits
	port (
	  A      : in  signed(7 downto 0);
	  B      : in  signed(7 downto 0);
	  setSub : in  bit;
	  S      : out signed(7 downto 0)
	);
	end component somaSub8Bits;

	component comparador
	port (
	  A : in  signed(7 downto 0);
	  B : in  signed(7 downto 0);
	  S : out bit
	);
	end component comparador;

	component reg8
	port (
	  E     : in  signed(7 downto 0);
	  S     : out signed(7 downto 0);
	  load  : in  bit;
	  reset : in  bit;
	  clk   : in  bit
	);
	end component reg8;

	component mux2to1
	port (
	  SEL : in  bit;
	  A   : in  signed(7 downto 0);
	  B   : in  signed(7 downto 0);
	  S   : out signed(7 downto 0)
	);
	end component mux2to1;


	component shift2
	port (
	  E : in  signed(7 downto 0);
	  S : out signed(7 downto 0)
	);
	end component shift2;


	signal square,delta,saida,somaA,somaB,squareIn,deltaIn,saidaIn : signed(7 downto 0);

		begin
	  somadorA: somador8bits port map(square, delta, somaA);
	  somadorB: somaSub8Bits port map(delta, "00000010",setSub,somaB);
	  compara: comparador port map(X, square, aletb);
	  mux1: mux2to1 port map(setIn,somaA,"00000001",squareIn);
	  mux2: mux2to1 port map(setIn,somaB,"00000011",deltaIn);
	  squareReg: reg8 port map(squareIn,square,loadSquare,reset,clk);
	  deltaReg: reg8 port map(deltaIn,delta,loadDelta,reset,clk);
	  saidaReg: reg8 port map(saidaIn,S,loadSaida,reset,clk);
	  shift: shift2 port map(somaB,saidaIn);
	  
	end architecture;


	library ieee;
	use ieee.numeric_bit.all;

	entity somador8bits is
	  port (
			A : in  signed(7 downto 0);
			B : in  signed(7 downto 0);
			S : out  signed(7 downto 0)
	  );
	end entity somador8bits;

	architecture hardware of somador8bits is
	begin
		S <= A + B;
	end architecture;

	library ieee;
	use ieee.numeric_bit.all;

	entity somaSub8Bits is
	  port (
			A : in  signed(7 downto 0);
			B : in  signed(7 downto 0);
			setSub: in bit;
			S : out  signed(7 downto 0)
	  );
	end entity somaSub8Bits;

	architecture hardware of somaSub8Bits is
	begin
		process(setSub,A,B)
		begin
			if setSub = '0' then
				S <= A + B;
			else
				S <= A - B;
			end if;
		end process;
	end architecture;


	library ieee;
	use ieee.numeric_bit.all;

	entity comparador is
	  port (
			A : in  signed(7 downto 0);
			B : in  signed(7 downto 0);
			S: out bit
	  );
	end entity comparador;

	architecture hardware of comparador is
	begin

		S <= '1' when A > B else '0';


	end architecture;

	library ieee;
	use ieee.numeric_bit.all;

	entity reg8 is
	  port (
			E : in  signed(7 downto 0);
			S : out  signed(7 downto 0);
			load: in bit;
			reset : in  bit; -- reset ativo alto assíncrono
			clk   : in  bit
	  );
	end entity reg8;

	architecture hardware of reg8 is
	begin
		process(clk,reset,load)
		 begin
			if reset = '1' then
			  s <= "00000000";
			elsif(clk'event and clk = '1') then
				if load = '1' then S <= E; end if;
			end if;
		end process;

	end architecture;

	library ieee;
	use ieee.numeric_bit.all;

	entity mux2to1 is
	  port (
			SEL : in  bit;
			A : in  signed(7 downto 0);
			B : in  signed(7 downto 0);
			S : out  signed(7 downto 0)
	  );
	end entity mux2to1;

	architecture hardware of mux2to1 is
	begin
		S <= A when (SEL = '0') else B;

	end architecture;


	library ieee;
	use ieee.numeric_bit.all;

	entity shift2 is
	  port (
			e : in  signed(7 downto 0);
			S : out  signed(7 downto 0)
	  );
	end entity shift2;

	architecture hardware of shift2 is
	begin
		S <= "0" & E(7 downto 1);

	end architecture;
