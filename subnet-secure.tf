resource "aws_subnet" "secure" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.default.cidr_block, var.newbits, count.index + var.secure_netnum_offset)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false
  tags                    = "${merge(map("Name", "${var.name}-Subnet-Secure-${upper(data.aws_availability_zone.az.*.name_suffix[count.index])}"), map("Scheme", "secure"), var.tags)}"
  depends_on              = ["aws_nat_gateway.nat_gw"]
}

resource "aws_route_table" "secure" {
  vpc_id = "${aws_vpc.default.id}"
  tags   = "${merge(map("Name", "${var.name}-RouteTable-Secure"), var.tags)}"
}

resource "aws_route_table_association" "secure" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${aws_subnet.secure.*.id[count.index]}"
  route_table_id = "${aws_route_table.secure.id}"

  lifecycle {
    ignore_changes        = ["subnet_id"]
    create_before_destroy = true
  }
}