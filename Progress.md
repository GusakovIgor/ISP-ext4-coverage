# Максимизация покрытия ext4

 Здесь будет подробная информация о проделанной работе.

## Окружение

### Ядро


- **Версия** - 6.8.5 (используемые [тэг](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tag/?h=v6.8.5) и [коммит](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?h=v6.8.5&id=b95f2066a910ace64787dc4f3e1dfcb2e7e71718))

- **Параметры конфигурации:**
    - В **menuconfig:**
        - `"CONFIG_DEBUG_FS=y"`
        - `“CONFIG_GCOV_KERNEL=y"`
        - `“CONFIG_XFS_FS=m"`
    - В **fs/ext4/Makefile:**
        - `“GCOV_PROFILE=y"`

### Хостовая машина

На ней собиралось ядро и анализировалось покрытие.

- OC - **Ubuntu 23.04**

### Тестовая машина

- OC - **Ubuntu 22.04**

- Является виртуальной машиной, запущенной с помощью **VirtualBox** версии 7.0.12 r159484 (Qt5.15.8) \
    (установлен с [официального сайта](https://www.virtualbox.org/), дата обращения: 12.04.2024).

- **Дисковое пространство:**
    - Основной раздел был отформатирован как `xfs`, чтобы исключить влияние действий в этом разделе на итоговое покрытие.
    - Были созданные два раздела для тестирования размером по 10ГБ. \
      Они отформатированы как `ext4`:
      - `/dev/sdb`
      - `/dev/sdc`

### Тесты
