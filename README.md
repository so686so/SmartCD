# SmartCD

- ### Using the linux ``cd`` command smarter

---

## Environment
- It works ``Linux``
- ``bash``

---

### Install
> 1. git clone https://github.com/so686so/SmartCD.git
> 1. cp -a ./.bash_aliases ${HOME}
> 1. source ~/.bashrc

---

### Command List
 > - prev (p)
 > - next (n)
 > - cdl
 > - cdc

---

### HOW TO USE

```cpp
// Example dirs tree
    A
    `-- B
        `-- C
            `-- D
                `-- E
```

```shell
    cd A
    cd B
    cd C
    cd D
    cd E
```

> For example, assume that you used cd in the order of A->B->C->D->E in the above folder structure.

- ### ``prev(p)`` / ``next(n)``
    - Move to the previous/next path among the paths moved by cd
        > **HOME@~/A/B/C/D/E$ ``prev``**  
        > { ~/A/B/C/D/E -> ~/A/B/C/D }  
        > **HOME@~/A/B/C/D$ ``p``**  
        > { ~/A/B/C/D -> ~/A/B/C }  

        > **HOME@~/A/B/C$ ``next``**  
        > { ~/A/B/C -> ~/A/B/C/D }  
        > **HOME@~/A/B/C/D$ ``n``**  
        > { ~/A/B/C/D -> ~/A/B/C/D/E }

- ### ``cdl``
    - cd list :: You can select and move one of the cd records
        > **HOME@~/A/B/C/D/E$ ``cdl``**  

        ```
        -----------------------------------------------------------------------------------------------
        Choose the path you want to move among the directories
        -----------------------------------------------------------------------------------------------
        1. HOME
        2. HOME/A
        3. HOME/A/B
        4. HOME/A/B/C
        5. HOME/A/B/C/D
        -----------------------------------------------------------------------------------------------
        * Use Arrow key to select and input 'Enter' to select, Cancel 'Ctrl+C'
        -----------------------------------------------------------------------------------------------
        ```

- ### `cdc`
    - cd clear :: Clear the record moved to cd