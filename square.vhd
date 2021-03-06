--------------------------------------------------------------------------------
--! 5307474 Bruno de Carvalho Albertini
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-- @brief Multiplexador
---- Estado: Implementado.
entity Multiplexador is
  port (
		Entrada1 : in signed (7 downto 0);
		Entrada2 : in signed (7 downto 0);
		Seletora : in std_logic;

		Saida    : out signed (7 downto 0)
  );

end entity Multiplexador;

architecture Multiplexador_arch of Multiplexador is
	begin
		Saida <= Entrada1 when (Seletora = '0') else
             Entrada2 when (Seletora = '1') else
             "11111111";

end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-- @brief Registrador
---- Estado: Implementado.
entity Registrador is
  port (
		Entrada : in signed (7 downto 0);
    load : in std_logic;
		clock : in std_logic;

		Saida    : out signed (7 downto 0)
  );

end entity Registrador;

architecture Registrador_arch of Registrador is
	begin
		process(clock, load)
    begin
      if (clock'event and clock = '1') then
        if (load = '1') then
          Saida <= Entrada;
        end if;
      end if;
    end process;

end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-- @brief Comparador
---- Estado: Implementado.
entity Comparador is
  port (
		EntradaA : in signed (7 downto 0);
    EntradaB : in signed (7 downto 0);

    AmaiorB  : out std_logic
  );

end entity Comparador;

architecture Comparador_arch of Comparador is
	begin

    AmaiorB <= '1' when (EntradaA > EntradaB) else
               '0' when (EntradaA <= EntradaB) else
               '0';

end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-- @brief Somador
---- Estado: Implementado.
entity Somador is
  port (
		Entrada1 : in signed (7 downto 0);
    Entrada2 : in signed (7 downto 0);
		Seletora : in std_logic;

		Saida    : out signed (7 downto 0)
  );

end entity Somador;

architecture Somador_arch of Somador is
	begin
		Saida <= (Entrada1 + Entrada2) when (Seletora = '0') else
             (Entrada1 - Entrada2) when (Seletora = '1') else
             "11111111";

end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-- @brief ShiftRight
---- Estado: Implementado.
entity ShiftRight is
  port (
		Entrada : in signed (7 downto 0);

		Saida    : out signed (7 downto 0)
  );

end entity ShiftRight;

architecture ShiftRight_arch of ShiftRight is
	begin
		Saida <= shift_right(signed(Entrada), 1);

end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-- @brief Raiz Quadrada
entity square is
  port (
    X     : in  signed(7 downto 0); -- entrada
    S     : out signed(7 downto 0); -- saida
    reset : in  std_logic; -- reset ativo alto assíncrono
    done  : out std_logic; -- alto quando terminou de calcular
    clk   : in  std_logic
  );
end entity square;

architecture square_arch of square is
  component square_fd is
    port (
      A : in signed (7 downto 0);
      clock : in std_logic;
      itera : in std_logic;
      done : in std_logic;
      reset : in std_logic;

      SgtA : out std_logic;
      Saida : out signed (7 downto 0)
    );
  end component;
  component square_uc is
    port (
      SgtA : in std_logic;
      clock : in std_logic;

      itera : out std_logic;
      done : out std_logic
    );
  end component;

  signal iteraUC, doneUC,SgtAFD : std_logic;

  begin
  fd: square_fd port map(X, clk, iteraUC, doneUC, reset, SgtAFD, S);
  uc: square_uc port map(SgtAFD, clk, iteraUC, doneUC);
  
  done <= doneUC;
end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-- @brief Raiz Quadrada
entity square_fd is
  port (
    A : in signed (7 downto 0);
    clock : in std_logic;
    itera : in std_logic;
    done : in std_logic;
    reset : in std_logic;

    SgtA : out std_logic;
    Saida : out signed (7 downto 0)
  );
end entity square_fd;

architecture square_fd_arch of square_fd is
  component Registrador is
    port (
      Entrada : in signed (7 downto 0);
      load : in std_logic;
      clock : in std_logic;

      Saida    : out signed (7 downto 0)
    );
  end component;
  component Multiplexador is
    port (
      Entrada1 : in signed (7 downto 0);
      Entrada2 : in signed (7 downto 0);
      Seletora : in std_logic;

      Saida    : out signed (7 downto 0)
    );
  end component;
  component Somador is
    port (
      Entrada1 : in signed (7 downto 0);
      Entrada2 : in signed (7 downto 0);
      Seletora : in std_logic;

      Saida    : out signed (7 downto 0)
    );
  end component;
  component Comparador is
    port (
      EntradaA : in signed (7 downto 0);
      EntradaB : in signed (7 downto 0);

      AmaiorB  : out std_logic
    );
  end component;
  component ShiftRight is
    port (
      Entrada : in signed (7 downto 0);

      Saida    : out signed (7 downto 0)
    );
  end component;
  signal saidaMux1, saidaMux2, saidaMux3, saidaSomador1, saidaSomador2: signed (7 downto 0);
  signal saidaRegA, saidaRegS, saidaRegD, saidaShift, saidaMux4, sinalSaida: signed (7 downto 0);
  begin
  regA: Registrador port map(A,reset,clock,saidaRegA);
  regS: Registrador port map(saidaMux1, (itera or reset),clock,saidaRegS);
  regD: Registrador port map(saidaMux2, (itera or reset),clock,saidaRegD);
  regM: Registrador port map(saidaSomador2,done,clock,sinalSaida);
  mux1: Multiplexador port map(saidaSomador1,"00000001",reset,saidaMux1);
  mux2: Multiplexador port map(saidaSomador2,"00000011",reset,saidaMux2);
  mux3: Multiplexador port map("00000010","00000001",done,saidaMux3);
  mux4: Multiplexador port map(saidaRegD,saidaShift,done,saidaMux4);
  shft: ShiftRight port map(saidaRegD, saidaShift);
  sum1: Somador port map(saidaRegS,saidaRegD,'0',saidaSomador1);
  sum2: Somador port map(saidaMux4,saidaMux3,done,saidaSomador2);
  sum3: Somador port map(sinalSaida, "00000001", '1', Saida);
  comp: Comparador port map(saidaRegS,saidaRegA,SgtA);
end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-- @brief Raiz Quadrada
entity square_uc is
  port (
    SgtA : in std_logic;
    clock : in std_logic;

    itera : out std_logic;
    done : out std_logic
  );
end entity square_uc;

architecture square_uc_arch of square_uc is
  begin
    my_process : process(clock)
    begin
			if(clock'event and clock='1')then
			  done <= SgtA;
			  itera <= not(SgtA);
			end if;
	  end process;
end architecture;
