# Maintainer: Pizze <piz2920@gmail.com>
pkgname="restic-backup-script"
pkgdesc=' A setup for a wrapper to do backups with restic'

pkgver=1.0.0
pkgrel=1
branch=master

arch=('any')
url='https://github.com/Tiefkuehlpizze/restic-backup-script'
license=('GPL')

depends=('restic')

backup=('etc/restic-backup/backup-env.sh')

source=("${pkgname}-${pkgver}.zip::https://github.com/Tiefkuehlpizze/restic-backup-script/archive/refs/tags/${pkgver}.zip")
sha256sums=('SKIP') #self reference

package() {
  cd "$srcdir/$pkgname-${pkgver}/"
  install -D -m 744 "backup.sh"  "$pkgdir/usr/bin/restic-backup.sh"
  install -D -m 644 "backup-env.sh" "$pkgdir/etc/restic-backup/backup-env.sh"
}

