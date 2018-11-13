--------------------------------------------------------------------------------
--! 5307474 Bruno de Carvalho Albertini
--------------------------------------------------------------------------------

-- @brief MDC
library ieee;
use ieee.numeric_bit.all;

entity mdc is
  port (
    X, Y  : in  signed(3 downto 0); -- entradas
    S     : out signed(3 downto 0); -- saida
    reset : in  bit; -- reset ativo alto assíncrono
    done  : out bit; -- alto quando terminou de calcular
    clk   : in bit
  );
end entity mdc;

architecture comp of mdc is
  component mdc_fd is
    port (
      A, B     : in  signed(3 downto 0); -- entradas
      S        : out signed(3 downto 0); -- saida
      ldX, ldY, ldM : in  bit; -- controle dos loads de X, Y e M
      selIn, selSub : in  bit; -- controle dos multiplexadores de entrada e do somador/subtrator
      XneqY, XltY   : out  bit -- saidas do comparador X!=Y e X<Y
    );
  end component;
  component mdc_uc is
    port (
      ldX, ldY, ldM : out bit; -- controle dos loads de X, Y e M
      selIn, selSub : out bit; -- controle dos multiplexadores de entrada e do somador/subtrator
      XneqY, XltY   : in  bit; -- saidas do comparador X!=Y e X<Y
      reset : in  bit; -- reset ativo alto assíncrono
      done  : out bit; -- alto quando terminou de calcular
      clk   : in  bit
    );
  end component;
  signal ldX, ldY, ldM, selIn, selSub, XneqY, XltY: bit;
begin
  fd: mdc_fd port map(X,Y,S,ldX, ldY, ldM, selIn, selSub, XneqY, XltY);
  uc: mdc_uc port map(ldX, ldY, ldM, selIn, selSub, XneqY, XltY, reset, done, clk);
end architecture;

-- @brief FD
library ieee;
use ieee.numeric_bit.all;

entity mdc_fd is
  port (
    A, B     : in  signed(3 downto 0); -- entradas
    S        : out signed(3 downto 0); -- saida
    ldX, ldY, ldM : in  bit; -- controle dos loads de X, Y e M
    selIn, selSub : in  bit; -- controle dos multiplexadores de entrada e do somador/subtrator
    XneqY, XltY   : out  bit -- saidas do comparador X!=Y e X<Y
  );
end entity mdc_fd;

architecture fd of mdc_fd is
  signal X, Y, M : signed (3 downto 0);
  signal XdiferenteY, XmenorY : bit;
begin
  X <= A when (ldX = '1');
  Y <= B when (ldY = '1');

  XdiferenteY <= '1' when (X /= Y) else '0';
  XmenorY <= '1' when (X < Y) else '0';

  XneqY <= '1' when (X /= Y) else '0';
  XltY <= '1' when (X < Y) else '0';

  my_process : process (ldM) is
  begin

    if (ldM = '1') then S <= M;
    else
      if (XdiferenteY = '1' and XmenorY = '0') then M <= Y;
      elsif (XmenorY = '1') then M <= X; X <= Y; Y <= M;
      end if;
      X <= X - M;
    end if;

  end process my_process;
end architecture;

-- @brief UC
library ieee;
use ieee.numeric_bit.all;

entity mdc_uc is
  port (
    ldX, ldY, ldM : out bit; -- controle dos loads de X, Y e M
    selIn, selSub : out bit; -- controle dos multiplexadores de entrada e do somador/subtrator
    XneqY, XltY   : in  bit; -- saidas do comparador X!=Y e X<Y
    reset : in  bit; -- reset ativo alto assíncrono
    done  : out bit; -- alto quando terminou de calcular
    clk   : in  bit
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
