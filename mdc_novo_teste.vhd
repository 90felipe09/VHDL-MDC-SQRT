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
		Entrada1 : in signed (3 downto 0);
    Entrada2 : in signed (3 downto 0);
		Seletora : in std_logic;

		Saida    : out signed (3 downto 0)
  );

end entity Multiplexador;

architecture Multiplexador_arch of Multiplexador is
	begin
		Saida <= Entrada1 when (Seletora = '0') else
             Entrada2 when (Seletora = '1') else
             "1111";

end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-- @brief Registrador
---- Estado: Implementado.
entity Registrador is
  port (
		Entrada : in signed (3 downto 0);
    load : in std_logic;
		clock : in std_logic;

		Saida    : out signed (3 downto 0)
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

-- @brief Somador
---- Estado: Implementado.
entity Somador is
  port (
		Entrada1 : in signed (3 downto 0);
    Entrada2 : in signed (3 downto 0);
		Seletora : in std_logic;

		Saida    : out signed (3 downto 0)
  );

end entity Somador;

architecture Somador_arch of Somador is
	begin
		Saida <= (Entrada1 + Entrada2) when (Seletora = '0') else
             (Entrada1 - Entrada2) when (Seletora = '1') else
             "1111";

end architecture;

library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

-- @brief Comparador
---- Estado: Implementado.
entity Comparador is
  port (
		EntradaA : in signed (3 downto 0);
    EntradaB : in signed (3 downto 0);

    AmenorB  : out std_logic;
    AdiferenteB  : out std_logic
  );

end entity Comparador;

architecture Comparador_arch of Comparador is
	begin

    AmenorB <= '0' when (EntradaA >= EntradaB) else
               '1' when (EntradaA < EntradaB) else
               '0';

    AdiferenteB <= '1' when (EntradaA /= EntradaB) else
                   '0' when (EntradaA = EntradaB) else
                   '0';

end architecture;

-- @brief MDC
library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

entity mdc is
  port (
    X, Y  : in  signed(3 downto 0); -- entradas
    S     : out signed(3 downto 0); -- saida
    reset : in  std_logic; -- reset ativo alto assíncrono
    done  : out std_logic; -- alto quando terminou de calcular
    clk   : in std_logic
  );
end entity mdc;

architecture comp of mdc is
  component mdc_fd is
    port (
      A, B     : in  signed(3 downto 0); -- entradas
      S        : out signed(3 downto 0); -- saida
      ldX, ldY, ldM : in  std_logic; -- controle dos loads de X, Y e M
      selIn, selSub : in  std_logic; -- controle dos multiplexadores de entrada e do somador/subtrator
      XneqY, XltY   : out  std_logic; -- saidas do comparador X!=Y e X<Y
      clk   : in  std_logic
    );
  end component;
  component mdc_uc is
    port (
      ldX, ldY, ldM : out std_logic; -- controle dos loads de X, Y e M
      selIn, selSub : out std_logic; -- controle dos multiplexadores de entrada e do somador/subtrator
      XneqY, XltY   : in  std_logic; -- saidas do comparador X!=Y e X<Y
      reset : in  std_logic; -- reset ativo alto assíncrono
      done  : out std_logic; -- alto quando terminou de calcular
      clk   : in  std_logic
    );
  end component;
  signal ldX, ldY, ldM, selIn, selSub, XneqY, XltY: std_logic;
begin
  fd: mdc_fd port map(X,Y,S,ldX, ldY, ldM, selIn, selSub, XneqY, XltY, clk);
  uc: mdc_uc port map(ldX, ldY, ldM, selIn, selSub, XneqY, XltY, reset, done, clk);
end architecture;

-- @brief FD
library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

entity mdc_fd is
  port (
    A, B     : in  signed(3 downto 0); -- entradas
    S        : out signed(3 downto 0); -- saida
    ldX, ldY, ldM : in  std_logic; -- controle dos loads de X, Y e M
    selIn, selSub : in  std_logic; -- controle dos multiplexadores de entrada e do somador/subtrator
    XneqY, XltY   : out  std_logic; -- saidas do comparador X!=Y e X<Y
    clk   : in  std_logic
  );
end entity mdc_fd;

architecture fd of mdc_fd is
  component Multiplexador is
    port(
      Entrada1 : in signed (3 downto 0);
      Entrada2 : in signed (3 downto 0);
  		Seletora : in std_logic;

  		Saida    : out signed (3 downto 0)
    );
  end component;

  component Registrador is
    port(
      Entrada : in signed (3 downto 0);
      load : in std_logic;
  		clock : in std_logic;

  		Saida    : out signed (3 downto 0)
    );
  end component;

  component Somador is
    port(
      Entrada1 : in signed (3 downto 0);
      Entrada2 : in signed (3 downto 0);
  		Seletora : in std_logic;

  		Saida    : out signed (3 downto 0)
    );
  end component;

  component Comparador is
    port(
      EntradaA : in signed (3 downto 0);
      EntradaB : in signed (3 downto 0);

      AdiferenteB  : out std_logic;
      AmenorB  : out std_logic
    );
  end component;

  signal saidaSomador, saidaMux1, saidaMux2, saidaMux3, saidaMux4, saidaRegX, saidaRegY, saidaRegM : signed (3 downto 0);
begin
  mux1: Multiplexador port map(A, saidaSomador, selIn, saidaMux1);
  mux2: Multiplexador port map(B, saidaSomador, selIn, saidaMux2);
  mux3: Multiplexador port map(saidaRegX, saidaRegY, selSub, saidaMux3);
  mux4: Multiplexador port map(saidaRegY, saidaRegX, selSub, saidaMux4);
  regX: Registrador port map(saidaMux1, ldX, clk, saidaRegX);
  regY: Registrador port map(saidaMux2, ldY, clk, saidaRegY);
  regM: Registrador port map(saidaRegX, ldM, clk, saidaRegM);
  comp: Comparador port map(saidaRegX, saidaRegY, XneqY, XltY);
  soma: Somador port map(saidaMux3, saidaMux4, '0', saidaSomador);
end architecture;

-- @brief UC
library ieee;
use ieee.numeric_bit.all;
use ieee.std_logic_1164.all;

entity mdc_uc is
  port (
    ldX, ldY, ldM : out std_logic; -- controle dos loads de X, Y e M
    selIn, selSub : out std_logic; -- controle dos multiplexadores de entrada e do somador/subtrator
    XneqY, XltY   : in  std_logic; -- saidas do comparador X!=Y e X<Y
    reset : in  std_logic; -- reset ativo alto assíncrono
    done  : out std_logic; -- alto quando terminou de calcular
    clk   : in  std_logic
  );
end entity mdc_uc;

architecture uc of mdc_uc is
  type estados is (E1, E2, E3, E4, E5, E6);
  signal estado : estados;
begin
  my_process : process(clk, reset, XneqY, XltY)
    begin
      if (reset = '1') then
        estado <= E1;
      elsif(clk'event and clk = '1') then
        case estado is
          when E1 =>
            if (XltY = '0' and XneqY = '1') then estado <= E2;
            elsif (XneqY = '0') then estado <= E6;
            elsif (XltY = '1') then estado <= E3;
            end if;

          when E2 =>
            if (XltY = '0' and XneqY = '1') then estado <= E4;
            elsif (XneqY = '0') then estado <= E6;
            elsif (XltY = '1') then estado <= E3;
            end if;

          when E3 =>
            if (XltY = '0' and XneqY = '1') then estado <= E2;
            elsif (XneqY = '0') then estado <= E6;
            elsif (XltY = '1') then estado <= E5;
            end if;

          when E4 =>
            estado <= E2;

          when E5 =>
            estado <= E3;

          when E6 =>
            estado <= E6;

        end case;
      end if;
    end process my_process;

  with estado select
    ldX <= '1' when E1,
           '1' when E4,
           '0' when others;

  with estado select
    ldY <= '1' when E1,
           '1' when E5,
           '0' when others;

  with estado select
    ldM <= '1' when E6,
           '0' when others;

  with estado select
    selIn <= '1' when E4,
             '1' when E5,
             '0' when others;

  with estado select
    selSub <= '1' when E5,
              '0' when others;

  with estado select
    done <= '1' when E6,
            '0' when others;
end architecture;
